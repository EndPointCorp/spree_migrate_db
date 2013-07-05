module SpreeMigrateDB
  class Runner
    def self.export(spree_version, schema_file, destination_dir)
      UI.say "Starting migration export for Spree #{spree_version}"
      header = {spree_version: spree_version}
      current_definition = CurrentSchemaDefinition.generate(schema_file)
      stats = GenerateExportDispatch.generate_migration_file(header, current_definition, destination_dir)
      UI.display_stats(stats)
    rescue => e
      UI.say "An error occurred during export."
      UI.say e.message
    end


    def self.import(spree_version, schema_file, import_file)
      UI.say "Starting database migration import for Spree #{spree_version}"
      current_definition = CurrentSchemaDefinition.generate(schema_file)
      import_file = MigrationFile.new(import_file)
      import_header = import_file.header
      import_definition = import_file.definition

      diff = import_definition.compare(current_definition)

      mapping = UI.map_menu diff

      rails_migration = RailsMigration.new(mapping)

      if UI.start_migration? import_header, rails_migration.stats
        rails_migration.run
        MigrationDataImport.run_import_file(import_file)
        UI.say "Import completed."
      end
    end




  end

end
