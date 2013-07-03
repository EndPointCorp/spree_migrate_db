require_relative 'generate_schema_dispatch'
require_relative 'generate_export_dispatch'
require_relative 'ui'

schema_definitions = Dir.glob("lib/spree_migrate_db/schema_definitions/*.rb")
schema_definitions.each {|sd| require sd }

module SpreeMigrateDB
  class Runner
    def self.export
      spree_version = Gem.loaded_specs["spree"].version.to_s
      puts "Starting migration export for Spree #{spree_version}"
      header = {spree_version: spree_version}
      current_definition = CurrentSchemaDefinition.generate
      stats = GenerateExportDispatch.generate_migration_file(header, current_definition)
      UI.display_stats(stats)
    rescue => e
      puts "An error occurred during export."
      puts e.message
    end
  end


end
