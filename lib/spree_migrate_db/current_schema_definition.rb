module SpreeMigrateDB
  class CurrentSchemaDefinition
    class NoCurrentSchemaFileError < StandardError; end
    def self.generate(spree_version, schema_file)
      raise NoCurrentSchemaFileError.new ("No schema file found at #{schema_file}") unless File.exist?(schema_file)

      schema = File.read(schema_file)
      schema.gsub!(/ActiveRecord::Schema.define\(:version => .*\)/, 'SpreeMigrateDB::SchemaDefinition.define "Application Definition"')

      definition = class_eval schema
      definition.version spree_version

      definition
    end

  end
end
