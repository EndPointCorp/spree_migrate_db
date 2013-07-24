require 'spec_helper'
require 'database_cleaner'

module SpreeMigrateDB
  describe MigrationDataImport do
    let(:mapping) { schema_diff.mapping }
    let(:import_file) { MigrationFile.new("spec/support/test_migration.stf") }

    before { DatabaseCleaner.start }
    after { DatabaseCleaner.clean }

    xit "runs the import as a class method" do
      mapping = import_file = ""
      mdi = MigrationDataImport.run_import_file(mapping, import_file)
      mdi.keys.should include :tables # just make sure you get back a stats hash
    end

    context "#run!" do
      it "imports the data into the database" do
        mdi = MigrationDataImport.new(mapping, import_file)
        mdi.run!
        ap mdi.stats

      end
    end


    def schema_diff
      current_definition = CurrentSchemaDefinition.generate("1.3.0", 'spec/support/schema_1_3_0.rb')
      diff = current_definition.compare(import_file.definition)
      ap diff.diff_id
      diff
    end

  end
end
