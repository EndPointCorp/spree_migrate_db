module SpreeMigrateDB
  FieldDef = DefStruct.new(:table, :column, :type, :options) do
    def to_s
      "#{table}.#{column}"
    end

    def ==(other)
      if other.kind_of? FieldDef
        to_s == other.to_s
      else
        false
      end
    end

  end

  TableDef = DefStruct.new(:name, :fields) do
    def column(name, type, opts={})
      fields << FieldDef.new(self.name, name, type, opts)
    end

    def method_missing(meth, *args)
      if %w[ string integer decimal datetime boolean text ].include? meth.to_s
        column args.shift, meth.to_sym, args.shift || {}
      else
        super
      end
    end

    def to_s
      name
    end

    def ==(other)
      if other === TableDef
        self.to_s == other.to_s
      else
        false
      end
    end

    def !=(other)
      ! self == other
    end


  end

  IndexDef = DefStruct.new(:name, :table, :fields, :options) do
    def to_s
      "#{table}.[#{fields.join(",")}]"
    end

  end

  class SchemaDefinition
    class InvalidSchemaHashError < StandardError; end

    def self.from_hash(schema_hash)
      h = schema_hash.deep_symbolize_keys
      d = new h.fetch(:name)
      d.version h.fetch(:version)
      h.fetch(:tables).each do |table_spec|
        table = table_spec.fetch(:name)
        columns = table_spec.fetch(:fields)
        
        d.create_table table do |t|
          columns.each do |c|
            t.column c.fetch(:column), c.fetch(:type), c.fetch(:options)
          end
        end
      end

      h.fetch(:indexes).each do |i|
        d.add_index i.fetch(:table), i.fetch(:fields), i.fetch(:name) { nil }, i.fetch(:options)
      end
      d

    rescue NoMethodError => nme
      raise InvalidSchemaHashError.new "Schema is not correctly formed. #{nme.message}"
    rescue KeyError => ke
      raise InvalidSchemaHashError.new "Expecting a key. #{ke.message}"
    end

    # setup the DSL
    def self.define(name, &block)
      definition = new(name)
      if block_given?
        if block.arity == 1
          yield definition
        else
          definition.instance_eval &block
        end
      end

      definition
    end

    def self.empty
      new("Empty")
    end

    attr_reader :name, :tables, :indexes, :spree_version

    def initialize(name)
      @name = name
      @tables = {}
      @indexes = Set.new
      @spree_version = ''
    end

    ## DSL Methods
    def version(v)
      @spree_version = v
    end

    def create_table(table_name, *args)
      @tables[table_name.to_sym] ||= TableDef.new(table_name, [])
      yield @tables[table_name.to_sym]
      @tables[table_name.to_sym]
    end

    def add_index(table, fields, name={}, options={})
      # sometimes the options are passed after the fields and 
      # sometimes the name is passed after the fields.
      # This little code helps figure that out
      index_options = options
      index_name = nil
      if name.kind_of? String
        index_name = name
      elsif name.kind_of? Hash
        index_options = name
      end
    
      i = IndexDef.new(index_name, table, fields.map(&:to_s), index_options)
      @indexes << i
      i
    end

    ######


    def ==(other_definition)
      to_hash == other_definition.to_hash
    end

    def to_s
      "SchemaDefinition #{@name} for Spree #{@spree_version}"
    end

    def inspect
      to_hash
    end

    def table_defs
      @table_defs ||= @tables.map { |t, td| td }
    end

    def lookup_table(table_name)
      @tables.fetch(table_name.to_sym) { TableDef.new(table_name, []) }
    end

    def lookup_table_by_table_def(table_def) 
      lookup_table(table_def.name)
    end

    def check_namespaced
      table_defs.any? { |t| t.canonical? && t.namespaced? }
    end

    def to_hash
      {
        :name => @name,
        :version => @spree_version,
        :tables => tables_list,
        :indexes => @indexes.map {|indexdef| indexdef.to_h }
      }.deep_symbolize_keys
    end

    def compare(other_definition)
      SchemaDefinitionDiff.new(self, other_definition)
    end

    def to_json
      to_hash.to_json
    end

    def subscribe 
      GenerateSchemaDispatch.subscribe self
      true

    rescue => e
      UI.say "Unable to subscribe definition #{self.to_s}. #{e.message}"
      false
    end

    private

    def tables_list
      l = []
      @tables.values.each do |tabledef|
        l << tabledef.to_h
      end
      l
    end

  end
end
