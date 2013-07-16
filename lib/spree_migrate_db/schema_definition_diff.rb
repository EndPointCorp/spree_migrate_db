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
      @actions = [ :ignore, :create, :rename, :skip ]
    end

    def action
      return @action if @action
      if current == export
        :ignore
      elsif current == :not_canonical
        :create
      elsif current != export
        :rename
      else
        :skip
      end
    end

  end

  IndexMappingItem = Class.new(MappingItem) do
    def type
      :index
    end

    def actions
      @actions = [ :ignore, :create, :recreate, :skip ]
    end

    def <=>(other)
      "#{export.table}#{export.name}" <=> "#{other.export.table}#{other.export.name}"
    end

    def action
      return @action if @action
      if current == :not_canonical || current == :not_found
        :create
      elsif options[:missing] && options[:new] && options[:missing].empty? && options[:new].empty?
        :ignore
      elsif ! options.empty?
        :recreate
      else
        :skip
      end
    end
  end

  FieldMappingItem = Class.new(MappingItem) do
    def type; :field; end

    def actions
      @actions = [ :create, :ignore, :skip ]
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
      elsif current == export
        :ignore
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
        mapping << TableMappingItem.new(canonical_name, t.name.to_s, {})
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
        next if tm.action == :skip

        if tm.action == :create
          other_table = @other_schema.lookup_table(tm.export)
          other_table.fields.each do |f|
            mapping << FieldMappingItem.new(:no_table, f)
          end
          next
        end

        
        current_fields = canonical_lookup.canonical_fields(@current_schema.lookup_table(tm.current))
        other_fields = canonical_lookup.canonical_fields(@other_schema.lookup_table(tm.export))

        missing, new, same = compare_arrays(current_fields, other_fields)

        missing.each do |m|
          mapping << FieldMappingItem.new(m, :default)
        end

        new.each do |d|
          mapping << FieldMappingItem.new(:no_field, d)
        end

        same.each do |s|
          mapping << FieldMappingItem.new(s, s)
        end

      end

      mapping
    end

    def compare_arrays(arr1, arr2)
      missing = arr1 - arr2
      new = arr2 - arr1
      same = arr1 & arr2

      [missing, new, same]
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
        unmatched << IndexMappingItem.new(:not_found, i, {})
      else
        indexes_with_same_fields.each do |ci|
          missing, new, same = compare_arrays(ci.fields, i.fields)
          unmatched << IndexMappingItem.new(ci, i, {:missing => missing, :new => new})
        end
      end
      unmatched
    end


  end

end
