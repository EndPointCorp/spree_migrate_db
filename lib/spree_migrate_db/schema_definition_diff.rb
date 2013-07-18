require 'digest/md5'
module SpreeMigrateDB

  MappingItem = Struct.new(:current, :export, :options) do
    def actions
      @actions = []
    end

    def action
      :unknown
    end

    def as_question
      "#{export} -> #{current} :: #{action}"
    end

    def question_opts
      actions
    end

    def save_action(action)
      return if action == :default || action == false
      @action = actions.detect{ |a| a.to_s[0].upcase == action }
      UI.say "Changed action to #{@action}."
    end

  end

  TableMappingItem = Class.new(MappingItem) do
    def type
      :table
    end

    def actions
      @actions = [ :create, :rename, :skip ]
    end

    def <=>(other)
      "#{export.name}" <=> "#{other.export.name}"
    end

    def action
      return @action if @action
      if current.name == :not_canonical
        :create
      else
        :skip
      end
    end

  end

  IndexMappingItem = Class.new(MappingItem) do
    def type
      :index
    end

    def canonical_table_name
      @c_table_name ||= options.fetch(:canonical_table_name) { export.table }
    end

    def actions
      @actions = [ :create, :recreate, :skip ]
    end

    def <=>(other)
      "#{export.table}#{export.name}" <=> "#{other.export.table}#{other.export.name}"
    end

    def action
      return @action if @action
      if current == :not_canonical || current == :not_found
        :create
      elsif options[:missing] && options[:new] && options[:missing].empty? && options[:new].empty?
        :skip
      elsif ! options.empty?
        :recreate
      else
        :skip
      end
    end

  end

  FieldMappingItem = Class.new(MappingItem) do
    def type; :field; end

    def as_question
     if (options && options.empty?) || options.nil?
       opts = ""
     else
       opts = ""
       options.each_pair do |k,v|
         opts << "\n  -- #{k}: '#{v}'"
       end
       opts << "\n"
     end
       
      
      "#{export} -> #{current} :: #{action}#{opts}"
    end

    def actions
      @actions = [ :create, :skip, :update ]
    end

    def <=>(other)
      "#{self.export}#{self.current}" <=> "#{other.export}#{other.current}"
    end

    def action
      return @action if @action
      if current == :no_table
        :skip
      elsif current == :no_field
        :create
      elsif current == export && ! options.empty?
        :update
      else
        :skip
      end
    end

  end


  class SchemaDefinitionDiff
    
    attr_accessor :mapping_dir
    attr_reader :mapping

    def initialize(current_schema, other_schema)
      @current_schema = current_schema
      @other_schema = other_schema
      @mapping_dir = ""
      @mapping = build_initial_mapping
    end

    def has_saved_mapping?
      File.exist? saved_mapping_file
    end

    def saved_mapping_file
      @saved_mapping_file ||= File.join(@mapping_dir, "mapping-#{diff_id}.map")
    end

    def load_mapping_from_file
      json_mapping = File.read(saved_mapping_file)
      @mapping = JSON.parse(json_mapping)
    end
    
    def save_mapping
      File.open saved_mapping_file, "w" do |f|
        f.write @mapping.to_json
      end
    end

    def identical?
      current_checksum == other_checksum
    end

    def diff_id
      "#{current_checksum}-#{other_checksum}"
    end

    private

    def current_checksum
      @current_checksum ||= checksum(@current_schema)
    end

    def other_checksum
      @other_checksum ||= checksum(@other_schema)
    end

    def checksum(schema)
      # WARNING: This will not work with ruby 1.8.x because order of hash keys isn't guaranteed.
      d = Digest::MD5.hexdigest schema.to_hash.to_s
      d.first(6) # don't need the whole thing
    end

    def build_initial_mapping
      m = {
        :tables => [],
        :indexes => [],
        :fields => []
      }
      return m if identical?

      m[:tables] = table_mappings
      m[:indexes] = index_mappings
      m[:fields] = field_mappings
      m
    end

    def table_mappings
      return @table_mapping if @table_mapping
      mapping = []
      @other_schema.table_defs.each do |t|
        canonical_name = canonical_lookup.canonical_table_name(t.name)
        current_table = @current_schema.lookup_table(canonical_name)
        mapping << TableMappingItem.new(current_table, t, {:canonical => canonical_name})
      end

      @table_mapping = mapping 
    end

    def index_mappings
      mapping = []
      @other_schema.indexes.each do |i|
        table_name = canonical_lookup.canonical_table_name(i.table)

        if table_name == :not_canonical
          mapping << IndexMappingItem.new(table_name, i, {})
        else
          mapping << unmatched_index_items(table_name, i)
        end
      end
      mapping.flatten
    end

    def field_mappings
      mapping = []
      table_mappings.each do |tm|
        next if tm.action == :create

        current_fields = canonical_lookup.canonical_fields(tm.current).simplify_elements
        other_fields = canonical_lookup.canonical_fields(tm.export).simplify_elements

        missing, new, same, all = compare_arrays(current_fields, other_fields)

        missing.each do |m|
          # compare the options
          el1, el2 = all.select{|el| el.to_s == m.to_s}
          if el2
            new_opts = el1.options.merge el2.options
            export = m
          else
            new_opts = {}
            export = :default
          end
          
          mapping << FieldMappingItem.new(m, export, new_opts)
        end

        new.each do |d|
          el1, el2 = all.select{|el| el.to_s == d.to_s}
          mapping << FieldMappingItem.new(:no_field, d) unless el2
        end

        same.each do |s|
          mapping << FieldMappingItem.new(s, s, {})
        end

      end

      mapping
    end

    def compare_arrays(arr1, arr2)
      missing = arr1 - arr2
      new = arr2 - arr1
      same = arr1 & arr2
      all = arr1 | arr2

      [missing, new, same, all]
    end


    def canonical_lookup
      @canonical_lookup ||= CanonicalSpree::Lookup.new(@current_schema.spree_version)
    end

    def index_lookup_for_table(table_name)
      @current_schema.indexes.select {|i| i.table.to_s == table_name.to_s}
    end


    def unmatched_index_items(table_name, i)
      indexes_for_current_table = index_lookup_for_table(table_name)
      indexes_with_same_fields = indexes_for_current_table.select do |ci|
        missing, new, same = compare_arrays(ci.fields, i.fields)
        ! same.empty?
      end

      unmatched = []

      if indexes_with_same_fields.empty?
        unmatched << IndexMappingItem.new(:not_found, i, {:canonical_table_name => table_name})
      else
        indexes_with_same_fields.each do |ci|
          missing, new, same = compare_arrays(ci.fields, i.fields)
          unmatched << IndexMappingItem.new(ci, i, {
            :canonical_table_name => table_name, 
            :missing => missing, 
            :new => new
          })
        end
      end
      unmatched
    end


  end

end
