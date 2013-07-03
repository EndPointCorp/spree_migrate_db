require 'spec_helper'
module SpreeMigrateDB
  describe Runner do
    it "runs an export" do
      Runner.export("0.50.0", "spec/support/schema.rb", "spec/support").should == true
    end
  end
end
