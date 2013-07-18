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
require_relative 'support/test_schema_definitions'
SpreeMigrateDB::UI.disable

