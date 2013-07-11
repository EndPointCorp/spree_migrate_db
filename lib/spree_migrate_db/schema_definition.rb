module SpreeMigrateDB
  FieldDef = Struct.new(:table, :column, :type, :options) do
    def to_h
      HashWithIndifferentAccess.new Hash[self.each_pair.to_a]
    end
  end

  TableDef = Struct.new(:name, :fields) do
    def column(name, type, opts={})
      fields << FieldDef.new(self.name, name, type, opts)
    end

    def to_h
      HashWithIndifferentAccess.new({name => fields.map{|f| f.to_h}})
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

  end

  IndexDef = Struct.new(:name, :table, :fields, :options) do
    def to_h
      HashWithIndifferentAccess.new Hash[self.each_pair.to_a]
    end

    def to_s
      "#{table}.[#{fields.join(",")}]"
    end
  end

  class SchemaDefinition
    class InvalidSchemaHashError < StandardError; end



    def self.from_hash(schema_hash)
      h = HashWithIndifferentAccess.new(schema_hash)
      d = new h.fetch(:name)
      d.version h.fetch(:version)
      h.fetch(:tables).each do |table, columns|
        d.create_table table do |t|
          columns.each do |c|
            t.column c.fetch(:column), c.fetch(:type), c.fetch(:options)
          end
        end
      end

      h.fetch(:indexes).each do |i|
        d.add_index i.fetch(:table), i.fetch(:fields), i.fetch(:name), i.fetch(:options)
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
      @tables[table_name] ||= TableDef.new(table_name, [])
      yield @tables[table_name]
      @tables[table_name]
    end

    def add_index(table, fields, name, options={})
      i = IndexDef.new(name, table, fields, options)
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

    def check_namespaced
      table_defs.any? { |t| t.canonical? && t.namespaced? }
    end

    def to_hash
      HashWithIndifferentAccess.new({
        :name => @name,
        :version => @spree_version,
        :tables => tables_hash,
        :indexes => @indexes.map {|indexdef| indexdef.to_h }
      })
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

    def tables_hash
      h = {}
      @tables.values.each do |tabledef|
        h.merge! tabledef.to_h
      end
      HashWithIndifferentAccess.new h
    end

  end
end
