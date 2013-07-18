require 'spec_helper'
module SpreeMigrateDB
  describe RailsMigration do
    let(:mapping) { SchemaDefinitionDiff.new(current_schema_definition, other_schema_definition).mapping }
    it "returns the changes that are to be made" do
      rm = RailsMigration.new(mapping) 
      rm.generate_migration_code
      rm.up_changes[:tables].count.should == 1
      rm.up_changes[:fields].count.should == 2
      rm.up_changes[:indexes].count.should == 3

      rm.down_changes[:tables].count.should == 1
      rm.down_changes[:fields].count.should == 2
      rm.down_changes[:indexes].count.should == 3
    end

    it "creates a migration file" do 
      rm = RailsMigration.new(mapping)
      rm.generate_migration_code
      rm.generate_migration_file("spec/support/migrations")
      rm.rails_migration_file.should be_kind_of RailsMigrationFile
      rm.rails_migration_file.path.should == "spec/support/migrations/spree_upgrade.rb"
      rm.rails_migration_file.body.should include "create_table"
    end

    it "runs the migrations"

    describe TableMigration do
      it "skips mappings that are marked not marked as create" do
        tm_mapping = mapping[:tables].detect {|m| m.action == :skip }
        tm = TableMigration.generate(tm_mapping)
        tm.up.should == nil
        tm.down.should == nil
      end

      it "generates a create_table migration for mappings marked as create" do
        migration_syntax = <<-RUBY.chomp
create_table :custom_table do |t|
      t.integer :id, key: true
      t.string :custom
    end
        RUBY

        tm_mapping = mapping[:tables].detect {|m| m.action == :create }
        tm = TableMigration.generate(tm_mapping)
        tm.up.should == migration_syntax 
        tm.down.should == "drop_table :custom_table"
      end
    end

    describe FieldMigration do

      it "converts the field definition to a standalone migration syntax" do
        m = mapping[:fields].detect {|m| m.action == :create }
        tm = FieldMigration.generate(m)
        tm.up.should == "add_column :spree_users, :email, :string, default: 'bob@example.com'"
        tm.down.should == "remove_column :spree_users, :email"
      end

      it "converts the field definition to a change migration" do
        m = mapping[:fields].detect {|m| m.action == :update }
        tm = FieldMigration.generate(m)
        tm.up.should == "change_column :spree_users, :name, :string, unique: true, default: 'nobody'"
        tm.down.should == "change_column :spree_users, :name, :string, unique: true"
      end

    end


    describe IndexMigration do
      it "converts the index definition to migration syntax with a name" do
        m = mapping[:indexes].detect {|m| m.export.name != nil && m.action == :create }
        tm = IndexMigration.generate(m)
        tm.up.should == "add_index :custom_table, [:custom], unique: true, name: 'custom_idx'"
        tm.down.should == "remove_index :custom_table, column: [:custom]"
      end

      it "converts the index definition to migration syntax with a name" do
        m = mapping[:indexes].detect {|m| m.action == :create }
        tm = IndexMigration.generate(m)
        tm.up.should == "add_index :spree_products, [:price]"
        tm.down.should == "remove_index :spree_products, column: [:price]"
      end

      it "recreates the index" do
        m = mapping[:indexes].detect {|m| m.action == :recreate }
        tm = IndexMigration.generate(m)

        tm.up.should == [
          "remove_index :spree_users, [:name]",
          "add_index :spree_users, [:name, :email], unique: true"
        ]

        tm.down.should == [
          "remove_index :spree_users, [:name, :email]",
          "add_index :spree_users, [:name], name: 'spree_users_name_idx'"
        ]
      end


    end
  end
end
