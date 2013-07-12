require 'rspec/autorun' unless ENV["no_rspec"]

require 'awesome_print'
require 'active_support/all'
require 'active_record'
require 'ostruct'

# swallow calls to Rails
module ::Rails
  def self.root; File.expand_path("../", File.dirname(__FILE__)); end
  def self.method_missing(a,*b); self; end
end

ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database => "spec/support/spree_migrate_db_test.db"
})


require 'spree_migrate_db'
SpreeMigrateDB::UI.disable

def valid_schema_definition
  SpreeMigrateDB::SchemaDefinition.define("test") do
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

def valid_schema_hash
  {
    :name => "test",
    :version => '0.50.0',
    :tables => [{
      :name => "users",
      :fields => [
        {:table => "users", :column => "id", :type => "integer", :options => {:key => true} },
        {:table => "users", :column => "name", :type => "string", :options => {}},
        {:table => "users", :column => "email", :type => "string", :options => {}}
      ]},{
      :name => "products",
      :fields => [
        {:table => "products", :column => "id", :type => "integer", :options => {:key => true} },
        {:table => "products", :column => "name", :type => "string", :options => {}},
      ]}, 
    ],
    :indexes => [
      {:name => "users_name_idx", :table => "users", :fields => ["name"], :options => {}}
  ]
  }
end

