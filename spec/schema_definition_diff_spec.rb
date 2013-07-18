require 'spec_helper'
module SpreeMigrateDB
  describe SchemaDefinitionDiff do

    let(:current_schema) {current_schema_definition }
    let(:other_schema) { other_schema_definition }
    let(:sdd) { SchemaDefinitionDiff.new(current_schema, other_schema)}

    context "#has_saved_mapping? and saved_mapping_file" do
      before { sdd.mapping_dir = "spec/support"}

      it "returns true if their is a mapping file" do
        FileUtils.touch(sdd.saved_mapping_file)
        sdd.has_saved_mapping?.should be_true
      end

      it "returns false if there isn't a mapping file" do
        FileUtils.rm(sdd.saved_mapping_file) if File.exist? sdd.saved_mapping_file
        sdd.has_saved_mapping?.should be_false
      end
    end

    context "#mapping" do

      it "returns a list of table map_items" do
        sdd.mapping[:tables].count.should == 4

        mi1, mi2, mi3, mi4 = sdd.mapping[:tables].sort

        mi1.current.name.should == :not_canonical
        mi1.export.name.should == "custom_table"
        mi1.options[:canonical].should == :not_canonical
        mi1.action.should == :create

        mi2.current.name.should == "spree_products"
        mi2.export.name.should == "products"
        mi2.options[:canonical].should == "spree_products"
        mi2.action.should == :skip

        mi3.current.name.should == "spree_users"
        mi3.export.name.should == "users"
        mi3.options[:canonical].should == "spree_users"
        mi3.action.should == :skip

        mi4.current.name.should == "spree_variants"
        mi4.export.name.should == "variants"
        mi4.options[:canonical].should == "spree_variants"
        mi4.action.should == :skip

      end

      it "returns a list of index map_items" do
        sdd.mapping[:indexes].count.should == 5

        # Each mapping demonstrates a permutation of possible outcomes.
        idx1, idx2, idx3, idx4, idx5 = sdd.mapping[:indexes].sort

        idx1.current.should == :not_canonical
        idx1.export.table.should == "custom_table"
        idx1.options.should be_empty
        idx1.action.should == :create

        idx2.current == :not_found
        idx2.export.table.should == "products"
        idx2.export.fields.should == ["price"]
        idx2.options[:canonical_table_name].should == "spree_products"
        idx2.action.should == :create

        idx3.current.table.should == "spree_products"
        idx3.export.table.should == "products"
        idx3.options[:new].should be_empty
        idx3.options[:missing].should be_empty
        idx3.action.should == :skip


        idx4.current.table.should == "spree_users"
        idx4.export.table.should == "users"
        idx4.options[:new].should == ["email"]
        idx4.options[:missing].should be_empty
        idx4.action.should == :recreate

        idx5.current.table.should == "spree_variants"
        idx5.export.table.should == "variants"
        idx5.options[:new].should be_empty
        idx5.options[:missing].should be_empty
        idx5.action.should == :skip
      end

      it "returns a list of field map_items" do
        sdd.mapping[:fields].count.should == 8
        mappings = sdd.mapping[:fields].sort.map do |m|
          m.as_question
        end

        mappings.should == [
          "spree_products.id -> spree_products.id :: skip",
          "spree_products.name -> spree_products.name :: skip",
          "spree_products.price -> spree_products.price :: skip",
          "spree_users.email -> no_field :: create",
          "spree_users.id -> spree_users.id :: skip",
          "spree_users.name -> spree_users.name :: update\n  -- unique: 'true'\n  -- default: 'nobody'\n",
          "spree_variants.id -> spree_variants.id :: skip",
          "spree_variants.sku -> spree_variants.sku :: skip"
        ]

      end
      
    end


  end
end
