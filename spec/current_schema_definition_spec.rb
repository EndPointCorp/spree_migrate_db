require 'spec_helper'
module SpreeMigrateDB

  describe CurrentSchemaDefinition do

    it "generates a schema file" do
      d = CurrentSchemaDefinition.generate('0.50.0','spec/support/schema.rb')
      d.to_s.should == "SchemaDefinition Application Definition for Spree 0.50.0"
    end

  end

end
