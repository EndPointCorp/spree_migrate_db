require 'lib/spree_migrate_db/schema_definition'

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
        d.to_hash.should == {
          :version => '0.50.0',
          :tables => { 
            :users => [
              {:column => :id, :type => :integer, :options => {:key => true} },
              {:column => :name, :type => :string, :options => {}},
              {:column => :email, :type => :string, :options => {}}
            ], 
            :products => [
              {:column => :id, :type => :integer, :options => {:key => true} },
              {:column => :name, :type => :string, :options => {}},
            ]
          },
          :indexes => [
            {:name => "users_name_idx", :table => :users, :fields => [:name], :options => {}}
          ]
        }
      end
    end

    context "#subscribe" do
      let(:d) { valid_schema_definition }

      it "subscribes to the schema dispatch" do
        d.subscribe.should == true
        GenerateSchemaDispatch.subscriptions.should include(d)
      end

    end

    # performs a subtraction diff where only missing elements from the 
    # calling object are returned in the new 
    #context "#diff when comparing two definitions" do
      #it "returns an EmptyDefinition if they are the same"
      #it "returns a new definition with table differences"
      #it "returns a new definition with index differences"
      #it "sets the version to a new version"
      #it "sets the name to a diff specific name"
    #end


    def valid_schema_definition
      SchemaDefinition.define("test") do
        version "0.50.0"
        create_table :users do |t|
          t.column :id, :integer, {:key => true}
          t.column :name, :string
          t.column :email, :string
        end
        create_table :products do |t| 
          t.column :id, :integer, {:key => true}
          t.column :name, :string
        end

        add_index :users, [:name], "users_name_idx"
      end
    end
  end
end
