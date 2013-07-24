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

module SpreeMigrateDB

  scrappy = ScrappyImport.new("spec/support/test_migration.stf")
  scrappy.import!

end
