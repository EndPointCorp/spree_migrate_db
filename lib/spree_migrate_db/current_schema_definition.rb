module SpreeMigrateDB
  class CurrentSchemaDefinition
    def self.generate
      schema_file = File.join(Rails.root, "db/schema.rb")
      raise NoCurrentSchemaFileError.new ("No schema file found at #{schema_file}") unless File.exist?(schema_file)

      schema = File.read(schema_file)
      schema.gsub!(/ActiveRecord::Schema.define\(:version => .*\)/, 'SpreeMigrateDB::SchemaDefinition.define "Application Definition"')

      definition = class_eval schema
      definition.version "Current"

      definition
    end

  end
end
