require 'ext/extensions'
require 'spree_migrate_db/version'
require 'spree_migrate_db/canonical_spree'
require 'spree_migrate_db/ui'
require 'spree_migrate_db/schema_definition'
require 'spree_migrate_db/schema_definition_diff'
require 'spree_migrate_db/current_schema_definition'
require 'spree_migrate_db/generate_export_dispatch'
require 'spree_migrate_db/generate_schema_dispatch'
require 'spree_migrate_db/migration_file'
require 'spree_migrate_db/runner'

require 'spree_migrate_db/railtie' if defined?(Rails)

module SpreeMigrateDB
  UI.enable
end
