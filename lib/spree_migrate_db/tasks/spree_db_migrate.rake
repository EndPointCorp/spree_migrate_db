require 'spree_migrate_db'
namespace :spree_migrate_db do
  desc "Creates a migration file based on your current db/schema.rb file."
  task :export => :environment do
    spree_version = Gem.loaded_specs["spree"].version.to_s
    raise "Spree not installed." unless spree_version

    schema_file = File.join(Rails.root, 'db/schema.rb')
    raise "#{schema_dir} does not exist!" unless File.exist? schema_file

    destination_dir = File.join(Rails.root, "tmp")

    SpreeMigrateDB::Runner.export(spree_version, schema_file, destination_dir)

  end

  desc "Imports a migration file created by export tmp/application_definition.stf"
  task :import => :environment do
    spree_version = Gem.loaded_specs["spree"].version.to_s
    raise "Spree not installed." unless spree_version

    schema_file = File.join(Rails.root, 'db/schema.rb')
    raise "#{schema_dir} does not exist!" unless File.exist? schema_file

    SpreeMigrateDB::Runner.import(spree_version, schema_file, "tmp/application_definition.stf")
  end

end
