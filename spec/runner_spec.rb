require 'spec_helper'
module SpreeMigrateDB
  describe Runner do
    it "runs an export" do
      Runner.export("0.50.0", "spec/support/schema.rb", "spec/support").should == true
    end

    it "runs an import" do
      Runner.import("1.3.0", "spec/support/schema_1_3_0.rb", "spec/support/test_migration.stf")
    end
  end
end
