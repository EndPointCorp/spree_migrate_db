module SpreeMigrateDB 
  module CanonicalSpree
    TABLES = {
      :products                 => {:spree_1x => "spree_products", :spree_0x                 => "products"},
      :users                    => {:spree_1x => "spree_users",    :spree_0x                 => "users"},
      :variants                 => {:spree_1x => "spree_variants", :spree_0x                 => "variants"},
      :addresses                => {:spree_1x => "spree_addresses", :spree_0x                => "addresses"},
      :adjustments              => {:spree_1x => "spree_adjustments", :spree_0x              => "adjustments"},
      :assets                   => {:spree_1x => "spree_assets", :spree_0x                   => "assets"},
      :calculators              => {:spree_1x => "spree_calculators", :spree_0x              => "calculators"},
      :configurations           => {:spree_1x => "spree_configurations", :spree_0x           => "configurations"},
      :countries                => {:spree_1x => "spree_countries", :spree_0x                => "countries"},
      :creditcards              => {:spree_1x => "spree_credit_cards", :spree_0x             => "creditcards"},
      :gateways                 => {:spree_1x => "spree_gateways", :spree_0x                 => "gateways"},
      :gift_cards               => {:spree_1x => "spree_gift_cards", :spree_0x               => "gift_cards"},
      :inventory_units          => {:spree_1x => "spree_inventory_units", :spree_0x          => "inventory_units"},
      :line_items               => {:spree_1x => "spree_line_items", :spree_0x               => "line_items"},
      :log_entries              => {:spree_1x => "spree_log_entries", :spree_0x              => "log_entries"},
      :mail_methods             => {:spree_1x => "spree_mail_methods", :spree_0x             => "mail_methods"},
      :option_types             => {:spree_1x => "spree_option_types", :spree_0x             => "option_types"},
      :option_types_prototypes  => {:spree_1x => "spree_option_types_prototypes", :spree_0x  => "option_types_prototypes"},
      :option_values            => {:spree_1x => "spree_option_values", :spree_0x            => "option_values"},
      :option_values_variants   => {:spree_1x => "spree_option_values_variants", :spree_0x   => "option_values_variants"},
      :orders                   => {:spree_1x => "spree_orders", :spree_0x                   => "orders"},
      :payment_methods          => {:spree_1x => "spree_payment_methods", :spree_0x          => "payment_methods"},
      :payments                 => {:spree_1x => "spree_payments", :spree_0x                 => "payments"},
      :preferences              => {:spree_1x => "spree_preferences", :spree_0x              => "preferences"},
      :product_groups           => {:spree_1x => "spree_product_groups", :spree_0x           => "product_groups"},
      :product_groups_products  => {:spree_1x => "spree_product_groups_products", :spree_0x  => "product_groups_products"},
      :product_option_types     => {:spree_1x => "spree_product_option_types", :spree_0x     => "product_option_types"},
      :product_properties       => {:spree_1x => "spree_product_properties", :spree_0x       => "product_properties"},
      :product_scopes           => {:spree_1x => "spree_product_scopes", :spree_0x           => "product_scopes"},
      :products_promotion_rules => {:spree_1x => "spree_products_promotion_rules", :spree_0x => "products_promotion_rules"},
      :products_taxons          => {:spree_1x => "spree_products_taxons", :spree_0x          => "products_taxons"},
      :product_taxons           => {:spree_1x => "spree_products_taxons", :spree_0x          => "product_taxons"},
      :promotion_rules          => {:spree_1x => "spree_promotion_rules", :spree_0x          => "promotion_rules"},
      :promotion_rules_users    => {:spree_1x => "spree_promotion_rules_users", :spree_0x    => "promotion_rules_users"},
      :promotions               => {:spree_1x => "spree_promotions", :spree_0x               => "promotions"},
      :properties               => {:spree_1x => "spree_properties", :spree_0x               => "properties"},
      :properties_prototypes    => {:spree_1x => "spree_properties_prototypes", :spree_0x    => "properties_prototypes"},
      :prototypes               => {:spree_1x => "spree_prototypes", :spree_0x               => "prototypes"},
      :return_authorizations    => {:spree_1x => "spree_return_authorizations", :spree_0x    => "return_authorizations"},
      :roles                    => {:spree_1x => "spree_roles", :spree_0x                    => "roles"},
      :roles_users              => {:spree_1x => "spree_roles_users", :spree_0x              => "roles_users"},
      :schema_migrations        => {:spree_1x => "spree_schema_migrations", :spree_0x        => "schema_migrations"},
      :shipments                => {:spree_1x => "spree_shipments", :spree_0x                => "shipments"},
      :shipping_categories      => {:spree_1x => "spree_shipping_categories", :spree_0x      => "shipping_categories"},
      :shipping_methods         => {:spree_1x => "spree_shipping_methods", :spree_0x         => "shipping_methods"},
      :state_events             => {:spree_1x => "spree_state_events", :spree_0x             => "state_events"},
      :states                   => {:spree_1x => "spree_states", :spree_0x                   => "states"},
      :tax_categories           => {:spree_1x => "spree_tax_categories", :spree_0x           => "tax_categories"},
      :tax_rates                => {:spree_1x => "spree_tax_rates", :spree_0x                => "tax_rates"},
      :taxonomies               => {:spree_1x => "spree_taxonomies", :spree_0x               => "taxonomies"},
      :taxons                   => {:spree_1x => "spree_taxons", :spree_0x                   => "taxons"},
      :tokenized_permissions    => {:spree_1x => "spree_tokenized_permissions", :spree_0x    => "tokenized_permissions"},
      :trackers                 => {:spree_1x => "spree_trackers", :spree_0x                 => "trackers"},
      :users                    => {:spree_1x => "spree_users", :spree_0x                    => "users"},
      :variants                 => {:spree_1x => "spree_variants", :spree_0x                 => "variants"},
      :volume_prices            => {:spree_1x => "spree_volume_prices", :spree_0x            => "volume_prices"},
      :zone_members             => {:spree_1x => "spree_zone_members", :spree_0x             => "zone_members"},
      :zones                    => {:spree_1x => "spree_zones", :spree_0x                    => "zones"},
    }

    SCHEMA_VERSIONS = [:spree_0x, :spree_1x]

    class Lookup
      def initialize(spree_version)
        @spree_version = spree_version
        @lookup_version = derive_schema_version_from_spree_version
      end

      def canonical_table_name(table_name)
        version_table_lookup(table_name)
      end

      # return an array of fields with the canonical table name
      def canonical_fields(table_def)
        table_def.fields.inject([]) do |fields, f|
          fields << SpreeMigrateDB::FieldDef.new(canonical_table_name(f.table), f.column, f.type, f.options)
        end
      end



      private 

      def derive_schema_version_from_spree_version
        major, minor, hotfix = @spree_version.split(".")

        if major == "0"
          :spree_0x
        elsif major == "1"
          :spree_1x
        else
          :unknown
        end
      end

      def version_table_lookup(table_name)
        a = TABLES.values.detect(->{{}}) {|spec| spec.has_value? table_name.to_s} 
        a.fetch(@lookup_version) { :not_canonical }
      end
    end


  end
end


