require 'spec_helper'

module SpreeMigrateDB
  describe SchemaDefinition do 
    context "define" do
      it "takes a block that passes an instance of itself" do
        SchemaDefinition.define("test") do |d|
          d.should be_instance_of SchemaDefinition
          d.name.should == "test"
        end
      end
      it "returns the instance of itself" do
        d = SchemaDefinition.define("test") 
        d.name.should == "test"
      end
    end

    context "#version" do
      it "sets the version" do
        d = SchemaDefinition.define("test") 
        d.version "0.50.0"
        d.spree_version.should == '0.50.0'
      end
    end

    context "#create_table" do
      let(:d) { SchemaDefinition.define("test") }

      it "takes a block with a name of the create_table" do
        table = d.create_table(:table_name) do |t|
          t.column(:id, :integer, {:key => true})

        end

        table.name.should == :table_name
        table.fields.first.column.should == :id
      end
    end

    context "#add_index" do
      let(:d) { valid_schema_definition }
      it "adds an index to the table" do
        i = d.add_index(:users, [:name], "nameidx")
        i.name.should == "nameidx"
        i.table.should == :users
        i.fields.should == [:name]
      end
    end

    context "#to_s" do
      let(:d) { SchemaDefinition.define("test") }

      it "should return a string with the name and version of the definition" do
        d.version "0.50.0"
        d.to_s.should == "SchemaDefinition test for Spree 0.50.0"
      end
    end

    context "#to_hash" do
      let(:d) { valid_schema_definition }

      it "returns a hash of the definition" do
        d.to_hash.should == valid_schema_hash
      end
    end

    context "#subscribe" do
      let(:d) { valid_schema_definition }

      it "subscribes to the schema dispatch" do
        d.subscribe.should == true
        GenerateSchemaDispatch.subscriptions.should include(d)
      end

    end


    context ".from_hash" do
      it "creates a new instance based on a passed hash" do
        sd = SchemaDefinition.from_hash valid_schema_hash

        sd.should be_kind_of SchemaDefinition
        sd.should == valid_schema_definition
      end

      it "returns an error if there is a problem parsing the hash" do
        invalid_schema_hash = valid_schema_hash
        invalid_schema_hash[:tables] = "invalid"
        expect {
          SchemaDefinition.from_hash invalid_schema_hash
        }.to raise_error SchemaDefinition::InvalidSchemaHashError
      end

      it "returns an error if a key is missing" do
        expect {
          SchemaDefinition.from_hash({:version => "0"})
        }.to raise_error SchemaDefinition::InvalidSchemaHashError
      end
    end

    context "#compare" do
      it "creates a SchemaDefinitionDiff object"  do
        d = SchemaDefinition.from_hash(valid_schema_hash)
        d.compare(valid_schema_definition).should be_kind_of SchemaDefinitionDiff
      end
    end


    context "accessors" do
      let(:d) { valid_schema_definition }

      it "returns a list of table defs" do
        d.table_defs.map(&:name).should == [:users, :products]
      end

    end


  end
end
