module SpreeMigrateDB
  describe GenerateExportDispatch do
    let(:d) { CurrentSchemaDefinition.generate }

    it "generates a migration file" do
      # TODO: Fix command-queryness
      stats = GenerateExportDispatch.generate_migration_file({:spree_version => "0.50.0"}, d)
      
      ap stats
    end
  end
end
