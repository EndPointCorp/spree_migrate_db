module SpreeMigrateDB
  class SchemaDefinition

    FieldDef = Struct.new(:column, :type, :options) do
      def to_h
        Hash[self.each_pair.to_a]
      end
    end

    TableDef = Struct.new(:name, :fields) do
      def column(name, type, opts={})
        fields << FieldDef.new(name, type, opts)
      end

      def to_h
        {name => fields.map{|f| f.to_h}}
      end

      def method_missing(meth, *args)
        if %w[ string integer decimal datetime boolean text ].include? meth.to_s
          column args.shift, meth.to_sym, args.shift || {}
        else
          super
        end
      end
    end

    IndexDef = Struct.new(:name, :table, :fields, :options) do
      def to_h
        Hash[self.each_pair.to_a]
      end
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

    attr_reader :name, :tables, :indexes, :spree_version

    def initialize(name)
      @name = name
      @tables = {}
      @indexes = Set.new
      @spree_version = ''
    end

    def version(v)
      @spree_version = v
    end

    def add_index(table, fields, name, options={})
      i = IndexDef.new(name, table, fields, options)
      @indexes << i
      i
    end


    def create_table(table_name, *args)
      @tables[table_name] ||= TableDef.new(table_name, [])
      yield @tables[table_name]
      @tables[table_name]
    end

    def to_s
      "SchemaDefinition #{@name} for Spree #{@spree_version}"
    end

    def to_hash
      {
        :version => @spree_version,
        :tables => tables_hash,
        :indexes => @indexes.map {|indexdef| indexdef.to_h }
      }
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

    def tables_hash
      h = {}
      @tables.values.each do |tabledef|
        h.merge! tabledef.to_h
      end
      h
    end


  end
end
