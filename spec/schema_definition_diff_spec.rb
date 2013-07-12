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
        mi = sdd.mapping[:tables].first
        mi.current.should == "spree_users"
        mi.export.should == "users"
        mi.type.should == :table
        mi.action.should == :rename

        mi2 = sdd.mapping[:tables].last
        mi2.current.should == :not_canonical
        mi2.export.should == "custom_table"
        mi2.type.should == :table
        mi2.action.should == :create
      end

      it "returns a list of index map_items" do
        sdd.mapping[:indexes].count.should == 5

        # Each mapping demonstrates a permutation of possible outcomes.
        idx1, idx2, idx3, idx4, idx5 = sdd.mapping[:indexes].sort

        idx1.current.should == :not_canonical
        idx1.export.table.should == :custom_table
        idx1.options.should be_empty
        idx1.action.should == :create

        idx2.current.table.should == :spree_products
        idx2.export.table.should == :products
        idx2.options[:new].should be_empty
        idx2.options[:missing].should be_empty
        idx2.action.should == :ignore

        idx3.current == :not_found
        idx3.export.table.should == :products
        idx3.export.fields.should == ["price"]
        idx3.options.should be_empty
        idx3.action.should == :create

        idx4.current.table.should == :spree_users
        idx4.export.table.should == :users
        idx4.options[:new].should == ["email"]
        idx4.action.should == :recreate

        idx5.current.table.should == :spree_variants
        idx5.export.table.should == :variants
        idx5.options[:new].should be_empty
        idx5.options[:missing].should be_empty
        idx5.action.should == :ignore


      end

      it "returns a list of field map_items" do
        #ap "running?"
        #ap sdd.mapping[:fields]

      end
      
    end


    def current_schema_definition
      h = {
        :name => "current schema",
        :version => '1.3.x',
        :tables => [{
          :name => "spree_users",
          :fields => [
            {:column => :id, :type => :integer, :options => {:key => true} },
            {:column => :name, :type => :string, :options => {}},
          ]}, {
          :name => "spree_products",
          :fields => [
            {:column => :id, :type => :integer, :options => {:key => true} },
            {:column => :name, :type => :string, :options => {}},
            {:column => :price, :type => :string, :options => {}},
          ]}, {
          :name => "spree_variants",
          :fields => [
            {:column => :id, :type => :integer, :options => {:key => true} },
            {:column => :sku, :type => :string, :options => {}}
          ]}
        ],
        :indexes => [
          {:name => "spree_users_name_idx", :table => :spree_users, :fields => [:name], :options => {}},
          {:name => "spree_products_name_idx", :table => :spree_products, :fields => [:name], :options => {}},
          {:name => "spree_variants_sku_idx", :table => :spree_variants, :fields => [:name], :options => {}}
        ]
        }

      SchemaDefinition.from_hash h
    end


    def other_schema_definition
      h = {
        :name => "other schema",
        :version => '0.5.0',
        :tables => [{
          :name => "users",
          :fields => [
            {:column => :id, :type => :integer, :options => {:key => true} },
            {:column => :name, :type => :string, :options => {}},
            {:column => :email, :type => :string, :options => {}},
          ]}, {
          :name => "products",
          :fields => [
            {:column => :id, :type => :integer, :options => {:key => true} },
            {:column => :name, :type => :string, :options => {}},
            {:column => :price, :type => :string, :options => {}},
          ]}, {
          :name => "variants",
          :fields => [
            {:column => :id, :type => :integer, :options => {:key => true} },
            {:column => :sku, :type => :string, :options => {}}
          ]}, {
          :name => "custom_table",
          :fields => [
            {:column => :id, :type => :integer, :options => {:key => true} },
            {:column => :custom, :type => :string, :options => {}}
          ]}
        ],
        :indexes => [
          {:name => "users_name_idx", :table => :users, :fields => [:name, :email], :options => {}},
          {:name => "products_name_idx", :table => :products, :fields => [:name], :options => {}},
          {:name => "products_price_idx", :table => :products, :fields => [:price], :options => {}},
          {:name => "variants_sku_idx", :table => :variants, :fields => [:name], :options => {}},
          {:name => "custom_idx", :table => :custom_table, :fields => [:custom], :options => {:unique => true}},
        ]
        }

      SchemaDefinition.from_hash h
    end
  end
end
