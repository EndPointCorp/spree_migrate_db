require 'spec_helper'
module SpreeMigrateDB
  describe Runner do
    it "runs an export" do
      Runner.export.should == true
    end
  end
end
