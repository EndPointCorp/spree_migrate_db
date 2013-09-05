require 'awesome_print'
require 'active_support/all'
require 'active_record'
require 'ostruct'

# swallow calls to Rails
module ::Rails
  def self.root; File.expand_path("../", File.dirname(__FILE__)); end
  def self.method_missing(a,*b); self; end
end


class SourceDatabase < ActiveRecord::Base
  establish_connection({
    :adapter => "sqlite3",
    :database => "spec/support/spree_migrate_db_source.db"
  })
end

ActiveRecord::Base.establish_connection({
    :adapter => "sqlite3",
    :database => "spec/support/spree_migrate_db_target.db"
  })

require 'spree_migrate_db'

unless defined? Spree::Image
  module Spree
    Asset = Class.new(ActiveRecord::Base)
    Asset.table_name = "spree_assets"
    Image = Class.new(Asset)

  end
end

module SpreeMigrateDB

  scrappy = ScrappyImport.new("spec/support/test_migration.stf", true)
  scrappy.import_tables

end
