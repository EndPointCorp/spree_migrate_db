require 'spec_helper'
module SpreeMigrateDB

  describe CurrentSchemaDefinition do

    it "generates a schema file" do
      d = CurrentSchemaDefinition.generate
      d.to_s.should == "SchemaDefinition Application Definition for Spree Current"
    end

  end

end