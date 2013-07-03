require 'spec_helper'
module SpreeMigrateDB
  describe GenerateExportDispatch do
    let(:d) { CurrentSchemaDefinition.generate("spec/support/schema.rb") }

    it "generates a migration file" do
      test_dir = File.join("spec/support")
      # TODO: Fix command-queryness
      stats = GenerateExportDispatch.generate_migration_file({:spree_version => "0.50.0"}, d, test_dir)
      
      ap stats
    end
  end
end
