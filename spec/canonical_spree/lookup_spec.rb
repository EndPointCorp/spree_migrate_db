require 'spec_helper'

module SpreeMigrateDB::CanonicalSpree
  describe Lookup do

    it "returns the canonical table name for the version" do
      l = Lookup.new("0.50.0")
      l.canonical_table_name("products").should == "products"
      l.canonical_table_name("spree_products").should == "products"

      l = Lookup.new("1.3.0-stable")
      l.canonical_table_name("products").should == "spree_products"
      l.canonical_table_name("spree_products").should == "spree_products"

    end

    it "returns an indicator that the table_name is not canonical" do
      l = Lookup.new("0.50.0")
      l.canonical_table_name("my_custom_table").should == :not_canonical

    end

  end
end
