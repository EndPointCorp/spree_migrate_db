require 'spree_migrate_db'
require 'rails'
module SpreeMigrateDB
  class Railtie < Rails::Railtie

    rake_tasks do
      #load "lib/spree_migrate_db/tasks/spree_migrate_db.rake"
      load File.expand_path('../tasks/spree_db_migrate.rake', __FILE__)
    end
  end
end
