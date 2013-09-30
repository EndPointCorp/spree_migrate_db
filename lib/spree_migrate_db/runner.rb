module SpreeMigrateDB
  class Runner
    def self.export(spree_version, schema_file, destination_dir)
      UI.say "Starting migration export for Spree #{spree_version}"
      header = {spree_version: spree_version}
      current_definition = CurrentSchemaDefinition.generate(spree_version, schema_file)
      stats = GenerateExportDispatch.generate_migration_file(header, current_definition, destination_dir)
      UI.display_stats(stats)
    rescue => e
      UI.say "An error occurred during export."
      UI.say e.message
      false
    end


    def self.import(spree_version, schema_file, import_file)
      clean = true
      scrappy = ScrappyImport.new(import_file, clean)
      scrappy.import_tables
    end

    #def self.import(spree_version, schema_file, import_file)
      #UI.say "Starting database migration import for Spree #{spree_version}"
      #current_definition = CurrentSchemaDefinition.generate(spree_version, schema_file)
      #import_dir = File.dirname(import_file)
      #import_file = MigrationFile.new(import_file)
      #import_header = import_file.header
      #import_definition = import_file.definition

      #diff = current_definition.compare(import_definition)
      #diff.mapping_dir = import_dir

      #updated_diff = UI.map_menu diff

      #rails_migration = RailsMigration.new(updated_diff.mapping)

      #if UI.start_migration? rails_migration
        #stats = MigrationDataImport.run_import_file(updated_diff.mapping, import_file)
        #UI.display_stats(stats)
      #end
    #rescue => e
      #UI.say "FATAL ERROR IN IMPORT"
      #UI.say e.message
      #puts e.message
      #puts e.backtrace.first(5).join("\n")
      #false
    #end







  end

end
