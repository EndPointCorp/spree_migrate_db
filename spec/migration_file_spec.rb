require 'spec_helper'
module SpreeMigrateDB
  describe MigrationFile do
    let(:import_file) { MigrationFile.new("spec/support/test_migration.stf") }

    it "returns the header of the file" do
      import_file.header.should == { "spree_version" => "0.50.0" }

    end

    it "builds a schema definition from the file" do
      import_file.definition.should be_kind_of SchemaDefinition
    end


  end
end
