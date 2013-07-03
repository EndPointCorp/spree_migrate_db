require "spree_migrate_db/version"

libs = Dir.glob("lib/spree_migrate_db/**/*.rb")
libs.each {|l| require_relative "../#{l}"}

module SpreeMigrateDB
  #spree_version = Gem.loaded_specs["spree"].version.to_s
  #set the schema dir
end
