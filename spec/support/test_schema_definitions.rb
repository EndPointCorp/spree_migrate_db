
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
    add_index :products, [:name], :unique => true
  end
end

def valid_schema_hash
  {
    "name" => "test",
    "version" => '0.50.0',
    "tables" => [{
      "name" => "users",
      "fields" => [
        {"table" => "users", "column" => "id", "type" => "integer", "options" => {"key" => true} },
        {"table" => "users", "column" => "name", "type" => "string", "options" => {}},
        {"table" => "users", "column" => "email", "type" => "string", "options" => {}}
      ]},{
      "name" => "products",
      "fields" => [
        {"table" => "products", "column" => "id", "type" => "integer", "options" => {"key" => true} },
        {"table" => "products", "column" => "name", "type" => "string", "options" => {}},
      ]}, 
    ],
    "indexes" => [
      {"name" => "users_name_idx", "table" => "users", "fields" => ["name"], "options" => {}},
      {"table" => "products", "fields" => ["name"], "options" => {"unique" => true}}
  ]
  }
end

def current_schema_definition
  h = {
    :name => "current schema",
    :version => '1.3.x',
    :tables => [{
    :name => "spree_users",
    :fields => [
      {:column => :id, :type => :integer, :options => {:key => true} },
      {:column => :name, :type => :string, :options => {:unique => true}},
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

  SpreeMigrateDB::SchemaDefinition.from_hash h
end


def other_schema_definition
  h = {
    :name => "other schema",
    :version => '0.5.0',
    :tables => [{
    :name => "users",
    :fields => [
      {:column => :id, :type => :integer, :options => {:key => true} },
      {:column => :name, :type => :string, :options => {:default => "nobody"}},
      {:column => :email, :type => :string, :options => {:default => "bob@example.com"}},
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
      {:name => "users_name_idx", :table => :users, :fields => [:name, :email], :options => {:unique => true}},
      {:name => "products_name_idx", :table => :products, :fields => [:name], :options => {}},
      {:table => :products, :fields => [:price], :options => {}},
      {:name => "variants_sku_idx", :table => :variants, :fields => [:name], :options => {}},
      {:name => "custom_idx", :table => :custom_table, :fields => [:custom], :options => {:unique => true}},
  ]
  }

  SpreeMigrateDB::SchemaDefinition.from_hash h
end
