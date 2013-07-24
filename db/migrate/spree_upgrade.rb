class SpreeUpgrade < ActiveRecord::Migration
  def self.up
    create_table :delayed_jobs do |t|
      t.integer :priority, default: '0'
      t.integer :attempts, default: '0'
      t.text :handler
      t.text :last_error
      t.datetime :run_at
      t.datetime :locked_at
      t.datetime :failed_at
      t.string :locked_by
      t.datetime :created_at
      t.datetime :updated_at
    end
    create_table :gift_cards do |t|
      t.string :number
      t.decimal :balance, precision: '10', scale: '2'
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :balance_updated_at
    end
    create_table :product_imports do |t|
      t.string :data_file_file_name
      t.string :data_file_content_type
      t.integer :data_file_file_size
      t.datetime :data_file_updated_at
      t.datetime :created_at
      t.datetime :updated_at
    end
    create_table :product_taxons do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :product_id
      t.integer :taxon_id
      t.integer :position, default: '1'
    end
    create_table :relation_types do |t|
      t.string :name
      t.text :description
      t.string :applies_to
      t.datetime :created_at
      t.datetime :updated_at
    end
    create_table :relations do |t|
      t.integer :relation_type_id
      t.integer :relatable_id
      t.string :relatable_type
      t.integer :related_to_id
      t.string :related_to_type
      t.datetime :created_at
      t.datetime :updated_at
      t.decimal :discount_amount, precision: '8', scale: '2', default: '0.0'
    end
    create_table :sessions do |t|
      t.string :session_id, null: false
      t.text :data
      t.datetime :created_at
      t.datetime :updated_at
    end
    create_table :ups_shipping_methods do |t|
      t.string :name
      t.string :abbr
      t.integer :shipping_method_id
      t.datetime :created_at
      t.datetime :updated_at
    end
    create_table :ups_worldship_shipments do |t|
      t.string :shipment_number, limit: '35'
      t.string :tracking_number, limit: '35'
      t.datetime :created_at, null: false
    end
    create_table :variants_promotion_rules do |t|
      t.integer :variant_id
      t.integer :promotion_rule_id
    end
    create_table :volume_prices do |t|
      t.integer :variant_id
      t.string :display
      t.string :range
      t.decimal :amount, precision: '8', scale: '2'
      t.integer :position
      t.datetime :created_at
      t.datetime :updated_at
    end
    create_table :zip_code_ranges do |t|
      t.string :start_zip
      t.string :end_zip
      t.datetime :created_at
      t.datetime :updated_at
    end
    change_column :spree_addresses, :created_at, :datetime, null: false
    change_column :spree_addresses, :updated_at, :datetime, null: false
    change_column :spree_adjustments, :amount, :decimal, precision: '8', scale: '2'
    change_column :spree_adjustments, :created_at, :datetime, null: false
    change_column :spree_adjustments, :updated_at, :datetime, null: false
    add_column :spree_adjustments, :order_id, :integer
    change_column :spree_assets, :viewable_type, :string, limit: '50'
    add_column :spree_assets, :attachment_size, :integer
    change_column :spree_calculators, :calculable_id, :integer, null: false
    change_column :spree_calculators, :calculable_type, :string, null: false
    change_column :spree_calculators, :created_at, :datetime, null: false
    change_column :spree_calculators, :updated_at, :datetime, null: false
    change_column :spree_configurations, :created_at, :datetime, null: false
    change_column :spree_configurations, :updated_at, :datetime, null: false
    add_column :spree_creditcards, :month, :string
    add_column :spree_creditcards, :year, :string
    add_column :spree_creditcards, :cc_type, :string
    add_column :spree_creditcards, :last_digits, :string
    add_column :spree_creditcards, :first_name, :string
    add_column :spree_creditcards, :last_name, :string
    add_column :spree_creditcards, :created_at, :datetime
    add_column :spree_creditcards, :updated_at, :datetime
    add_column :spree_creditcards, :start_month, :string
    add_column :spree_creditcards, :start_year, :string
    add_column :spree_creditcards, :issue_number, :string
    add_column :spree_creditcards, :address_id, :integer
    add_column :spree_creditcards, :gateway_customer_profile_id, :string
    add_column :spree_creditcards, :gateway_payment_profile_id, :string
    change_column :spree_gateways, :created_at, :datetime, null: false
    change_column :spree_gateways, :updated_at, :datetime, null: false
    change_column :spree_inventory_units, :created_at, :datetime, null: false
    change_column :spree_inventory_units, :updated_at, :datetime, null: false
    change_column :spree_line_items, :created_at, :datetime, null: false
    change_column :spree_line_items, :updated_at, :datetime, null: false
    change_column :spree_log_entries, :created_at, :datetime, null: false
    change_column :spree_log_entries, :updated_at, :datetime, null: false
    change_column :spree_mail_methods, :created_at, :datetime, null: false
    change_column :spree_mail_methods, :updated_at, :datetime, null: false
    change_column :spree_option_types, :created_at, :datetime, null: false
    change_column :spree_option_types, :updated_at, :datetime, null: false
    add_column :spree_option_types_prototypes, :position, :integer, default: '1'
    change_column :spree_option_values, :created_at, :datetime, null: false
    change_column :spree_option_values, :updated_at, :datetime, null: false
    add_column :spree_option_values, :sku, :string
    add_column :spree_option_values, :amount, :decimal, precision: '10', scale: '2', default: '0.0'
    change_column :spree_orders, :item_total, :decimal, precision: '8', scale: '2', default: '0.0', null: false
    change_column :spree_orders, :total, :decimal, precision: '8', scale: '2', default: '0.0', null: false
    change_column :spree_orders, :adjustment_total, :decimal, precision: '8', scale: '2', default: '0.0', null: false
    change_column :spree_orders, :payment_total, :decimal, precision: '8', scale: '2', default: '0.0'
    change_column :spree_orders, :created_at, :datetime, null: false
    change_column :spree_orders, :updated_at, :datetime, null: false
    add_column :spree_orders, :credit_total, :decimal, precision: '8', scale: '2', default: '0.0', null: false
    add_column :spree_orders, :name, :string
    add_column :spree_orders, :is_broadway_customer, :boolean, default: false
    add_column :spree_orders, :accountnumber, :string
    add_column :spree_orders, :checked_subscribe_at, :datetime
    add_column :spree_orders, :add_to_mailing_list, :boolean, default: true
    add_column :spree_orders, :viewed_at, :datetime
    change_column :spree_payment_methods, :created_at, :datetime, null: false
    change_column :spree_payment_methods, :updated_at, :datetime, null: false
    change_column :spree_payments, :amount, :decimal, precision: '8', scale: '2', default: '0.0', null: false
    change_column :spree_payments, :created_at, :datetime, null: false
    change_column :spree_payments, :updated_at, :datetime, null: false
    change_column :spree_preferences, :created_at, :datetime, null: false
    change_column :spree_preferences, :updated_at, :datetime, null: false
    add_column :spree_preferences, :name, :string, limit: '100', null: false
    add_column :spree_preferences, :owner_id, :integer, null: false
    add_column :spree_preferences, :owner_type, :string, limit: '50', null: false
    add_column :spree_preferences, :group_id, :integer
    add_column :spree_preferences, :group_type, :string, limit: '50'
    add_column :spree_product_groups, :name, :string
    add_column :spree_product_groups, :permalink, :string
    add_column :spree_product_groups, :order, :string
    add_column :spree_product_groups_products, :product_id, :integer
    add_column :spree_product_groups_products, :product_group_id, :integer
    change_column :spree_product_option_types, :created_at, :datetime, null: false
    change_column :spree_product_option_types, :updated_at, :datetime, null: false
    change_column :spree_product_properties, :created_at, :datetime, null: false
    change_column :spree_product_properties, :updated_at, :datetime, null: false
    add_column :spree_product_scopes, :product_group_id, :integer
    add_column :spree_product_scopes, :name, :string
    add_column :spree_product_scopes, :arguments, :text
    change_column :spree_products, :count_on_hand, :integer, default: '50000', null: false
    change_column :spree_products, :created_at, :datetime, null: false
    change_column :spree_products, :updated_at, :datetime, null: false
    add_column :spree_products, :display_type, :integer, default: '2'
    add_column :spree_products, :short_description, :text
    add_column :spree_products, :instructions, :text
    add_column :spree_products, :whatsnew, :boolean
    change_column :spree_promotion_rules, :created_at, :datetime, null: false
    change_column :spree_promotion_rules, :updated_at, :datetime, null: false
    add_column :spree_promotion_rules, :promotion_id, :integer
    add_column :spree_promotions, :code, :string
    add_column :spree_promotions, :description, :string
    add_column :spree_promotions, :usage_limit, :integer
    add_column :spree_promotions, :combine, :boolean
    add_column :spree_promotions, :expires_at, :datetime
    add_column :spree_promotions, :created_at, :datetime
    add_column :spree_promotions, :updated_at, :datetime
    add_column :spree_promotions, :starts_at, :datetime
    add_column :spree_promotions, :match_policy, :string, default: 'all'
    add_column :spree_promotions, :name, :string
    add_column :spree_promotions, :promote, :boolean
    change_column :spree_properties, :created_at, :datetime, null: false
    change_column :spree_properties, :updated_at, :datetime, null: false
    change_column :spree_prototypes, :created_at, :datetime, null: false
    change_column :spree_prototypes, :updated_at, :datetime, null: false
    change_column :spree_return_authorizations, :amount, :decimal, precision: '8', scale: '2', default: '0.0', null: false
    change_column :spree_return_authorizations, :created_at, :datetime, null: false
    change_column :spree_return_authorizations, :updated_at, :datetime, null: false
    change_column :spree_shipments, :created_at, :datetime, null: false
    change_column :spree_shipments, :updated_at, :datetime, null: false
    add_column :spree_shipments, :fedex_account, :string, limit: '50'
    change_column :spree_shipping_categories, :created_at, :datetime, null: false
    change_column :spree_shipping_categories, :updated_at, :datetime, null: false
    change_column :spree_shipping_methods, :created_at, :datetime, null: false
    change_column :spree_shipping_methods, :updated_at, :datetime, null: false
    add_column :spree_shipping_methods, :hide_shipping_cost, :boolean, default: false
    add_column :spree_shipping_methods, :display_order, :integer
    add_column :spree_state_events, :stateful_id, :integer
    add_column :spree_state_events, :user_id, :integer
    add_column :spree_state_events, :name, :string
    add_column :spree_state_events, :created_at, :datetime
    add_column :spree_state_events, :updated_at, :datetime
    add_column :spree_state_events, :previous_state, :string
    add_column :spree_state_events, :stateful_type, :string
    add_column :spree_state_events, :next_state, :string
    change_column :spree_tax_categories, :created_at, :datetime, null: false
    change_column :spree_tax_categories, :updated_at, :datetime, null: false
    change_column :spree_tax_rates, :amount, :decimal, precision: '8', scale: '4'
    change_column :spree_tax_rates, :created_at, :datetime, null: false
    change_column :spree_tax_rates, :updated_at, :datetime, null: false
    change_column :spree_taxonomies, :created_at, :datetime, null: false
    change_column :spree_taxonomies, :updated_at, :datetime, null: false
    add_column :spree_taxonomies, :sort_order, :integer
    change_column :spree_taxons, :taxonomy_id, :integer, null: false
    change_column :spree_taxons, :created_at, :datetime, null: false
    change_column :spree_taxons, :updated_at, :datetime, null: false
    add_column :spree_taxons, :instructions, :text
    change_column :spree_tokenized_permissions, :created_at, :datetime, null: false
    change_column :spree_tokenized_permissions, :updated_at, :datetime, null: false
    change_column :spree_trackers, :created_at, :datetime, null: false
    change_column :spree_trackers, :updated_at, :datetime, null: false
    change_column :spree_users, :encrypted_password, :string, limit: '128'
    change_column :spree_users, :password_salt, :string, limit: '128'
    change_column :spree_users, :created_at, :datetime, null: false
    change_column :spree_users, :updated_at, :datetime, null: false
    change_column :spree_variants, :count_on_hand, :integer, default: '50000', null: false
    add_column :spree_variants, :price, :decimal, precision: '8', scale: '2', null: false
    add_column :spree_variants, :stock_type, :integer, default: '2'
    add_column :spree_variants, :background_shade, :boolean
    change_column :spree_zone_members, :created_at, :datetime, null: false
    change_column :spree_zone_members, :updated_at, :datetime, null: false
    change_column :spree_zones, :created_at, :datetime, null: false
    change_column :spree_zones, :updated_at, :datetime, null: false
    add_index :spree_adjustments, [:order_id], name: 'index_adjustments_on_order_id'
    add_index :delayed_jobs, [:priority, :run_at], name: 'delayed_jobs_priority'
    add_index :gift_cards, [:number], name: 'index_gift_cards_on_number'
    add_index :spree_option_values, [:option_type_id], name: 'index_option_values_on_option_type_id'
    remove_index :spree_option_values_variants, [:variant_id]
    add_index :spree_option_values_variants, [:variant_id, :option_value_id], name: 'index_option_values_variants_on_variant_id_and_option_value_id'
    remove_index :spree_option_values_variants, [:variant_id, :option_value_id]
    add_index :spree_option_values_variants, [:variant_id], name: 'index_option_values_variants_on_variant_id'
    add_index :spree_preferences, [:owner_id, :owner_type, :name, :group_id, :group_type], name: 'ix_prefs_on_owner_attr_pref', unique: true
    add_index :spree_product_groups, [:name], name: 'index_product_groups_on_name'
    add_index :spree_product_groups, [:permalink], name: 'index_product_groups_on_permalink'
    add_index :spree_product_scopes, [:name], name: 'index_product_scopes_on_name'
    add_index :spree_product_scopes, [:product_group_id], name: 'index_product_scopes_on_product_group_id'
    add_index :sessions, [:session_id], name: 'index_sessions_on_session_id'
    add_index :sessions, [:updated_at], name: 'index_sessions_on_updated_at'
    add_index :spree_users, [:persistence_token], name: 'index_users_on_persistence_token'
    add_index :variants_promotion_rules, [:promotion_rule_id], name: 'index_variants_promotion_rules_on_promotion_rule_id'
    add_index :variants_promotion_rules, [:variant_id], name: 'index_variants_promotion_rules_on_variant_id'
    add_index :volume_prices, [:variant_id], name: 'variant_id_index'
  end

  def self.down
    drop_table :delayed_jobs
    drop_table :gift_cards
    drop_table :product_imports
    drop_table :product_taxons
    drop_table :relation_types
    drop_table :relations
    drop_table :sessions
    drop_table :ups_shipping_methods
    drop_table :ups_worldship_shipments
    drop_table :variants_promotion_rules
    drop_table :volume_prices
    drop_table :zip_code_ranges
    change_column :spree_addresses, :created_at, :datetime, null: false
    change_column :spree_addresses, :updated_at, :datetime, null: false
    change_column :spree_adjustments, :amount, :decimal, precision: '10', scale: '2'
    change_column :spree_adjustments, :created_at, :datetime, null: false
    change_column :spree_adjustments, :updated_at, :datetime, null: false
    remove_column :spree_adjustments, :order_id
    change_column :spree_assets, :viewable_type, :string
    remove_column :spree_assets, :attachment_size
    change_column :spree_calculators, :calculable_id, :integer
    change_column :spree_calculators, :calculable_type, :string
    change_column :spree_calculators, :created_at, :datetime, null: false
    change_column :spree_calculators, :updated_at, :datetime, null: false
    change_column :spree_configurations, :created_at, :datetime, null: false
    change_column :spree_configurations, :updated_at, :datetime, null: false
    remove_column :spree_creditcards, :month
    remove_column :spree_creditcards, :year
    remove_column :spree_creditcards, :cc_type
    remove_column :spree_creditcards, :last_digits
    remove_column :spree_creditcards, :first_name
    remove_column :spree_creditcards, :last_name
    remove_column :spree_creditcards, :created_at
    remove_column :spree_creditcards, :updated_at
    remove_column :spree_creditcards, :start_month
    remove_column :spree_creditcards, :start_year
    remove_column :spree_creditcards, :issue_number
    remove_column :spree_creditcards, :address_id
    remove_column :spree_creditcards, :gateway_customer_profile_id
    remove_column :spree_creditcards, :gateway_payment_profile_id
    change_column :spree_gateways, :created_at, :datetime, null: false
    change_column :spree_gateways, :updated_at, :datetime, null: false
    change_column :spree_inventory_units, :created_at, :datetime, null: false
    change_column :spree_inventory_units, :updated_at, :datetime, null: false
    change_column :spree_line_items, :created_at, :datetime, null: false
    change_column :spree_line_items, :updated_at, :datetime, null: false
    change_column :spree_log_entries, :created_at, :datetime, null: false
    change_column :spree_log_entries, :updated_at, :datetime, null: false
    change_column :spree_mail_methods, :created_at, :datetime, null: false
    change_column :spree_mail_methods, :updated_at, :datetime, null: false
    change_column :spree_option_types, :created_at, :datetime, null: false
    change_column :spree_option_types, :updated_at, :datetime, null: false
    remove_column :spree_option_types_prototypes, :position
    change_column :spree_option_values, :created_at, :datetime, null: false
    change_column :spree_option_values, :updated_at, :datetime, null: false
    remove_column :spree_option_values, :sku
    remove_column :spree_option_values, :amount
    change_column :spree_orders, :item_total, :decimal, precision: '10', scale: '2', default: '0.0', null: false
    change_column :spree_orders, :total, :decimal, precision: '10', scale: '2', default: '0.0', null: false
    change_column :spree_orders, :adjustment_total, :decimal, precision: '10', scale: '2', default: '0.0', null: false
    change_column :spree_orders, :payment_total, :decimal, precision: '10', scale: '2', default: '0.0'
    change_column :spree_orders, :created_at, :datetime, null: false
    change_column :spree_orders, :updated_at, :datetime, null: false
    remove_column :spree_orders, :credit_total
    remove_column :spree_orders, :name
    remove_column :spree_orders, :is_broadway_customer
    remove_column :spree_orders, :accountnumber
    remove_column :spree_orders, :checked_subscribe_at
    remove_column :spree_orders, :add_to_mailing_list
    remove_column :spree_orders, :viewed_at
    change_column :spree_payment_methods, :created_at, :datetime, null: false
    change_column :spree_payment_methods, :updated_at, :datetime, null: false
    change_column :spree_payments, :amount, :decimal, precision: '10', scale: '2', default: '0.0', null: false
    change_column :spree_payments, :created_at, :datetime, null: false
    change_column :spree_payments, :updated_at, :datetime, null: false
    change_column :spree_preferences, :created_at, :datetime, null: false
    change_column :spree_preferences, :updated_at, :datetime, null: false
    remove_column :spree_preferences, :name
    remove_column :spree_preferences, :owner_id
    remove_column :spree_preferences, :owner_type
    remove_column :spree_preferences, :group_id
    remove_column :spree_preferences, :group_type
    remove_column :spree_product_groups, :name
    remove_column :spree_product_groups, :permalink
    remove_column :spree_product_groups, :order
    remove_column :spree_product_groups_products, :product_id
    remove_column :spree_product_groups_products, :product_group_id
    change_column :spree_product_option_types, :created_at, :datetime, null: false
    change_column :spree_product_option_types, :updated_at, :datetime, null: false
    change_column :spree_product_properties, :created_at, :datetime, null: false
    change_column :spree_product_properties, :updated_at, :datetime, null: false
    remove_column :spree_product_scopes, :product_group_id
    remove_column :spree_product_scopes, :name
    remove_column :spree_product_scopes, :arguments
    change_column :spree_products, :count_on_hand, :integer, default: '0'
    change_column :spree_products, :created_at, :datetime, null: false
    change_column :spree_products, :updated_at, :datetime, null: false
    remove_column :spree_products, :display_type
    remove_column :spree_products, :short_description
    remove_column :spree_products, :instructions
    remove_column :spree_products, :whatsnew
    change_column :spree_promotion_rules, :created_at, :datetime, null: false
    change_column :spree_promotion_rules, :updated_at, :datetime, null: false
    remove_column :spree_promotion_rules, :promotion_id
    remove_column :spree_promotions, :code
    remove_column :spree_promotions, :description
    remove_column :spree_promotions, :usage_limit
    remove_column :spree_promotions, :combine
    remove_column :spree_promotions, :expires_at
    remove_column :spree_promotions, :created_at
    remove_column :spree_promotions, :updated_at
    remove_column :spree_promotions, :starts_at
    remove_column :spree_promotions, :match_policy
    remove_column :spree_promotions, :name
    remove_column :spree_promotions, :promote
    change_column :spree_properties, :created_at, :datetime, null: false
    change_column :spree_properties, :updated_at, :datetime, null: false
    change_column :spree_prototypes, :created_at, :datetime, null: false
    change_column :spree_prototypes, :updated_at, :datetime, null: false
    change_column :spree_return_authorizations, :amount, :decimal, precision: '10', scale: '2', default: '0.0', null: false
    change_column :spree_return_authorizations, :created_at, :datetime, null: false
    change_column :spree_return_authorizations, :updated_at, :datetime, null: false
    change_column :spree_shipments, :created_at, :datetime, null: false
    change_column :spree_shipments, :updated_at, :datetime, null: false
    remove_column :spree_shipments, :fedex_account
    change_column :spree_shipping_categories, :created_at, :datetime, null: false
    change_column :spree_shipping_categories, :updated_at, :datetime, null: false
    change_column :spree_shipping_methods, :created_at, :datetime, null: false
    change_column :spree_shipping_methods, :updated_at, :datetime, null: false
    remove_column :spree_shipping_methods, :hide_shipping_cost
    remove_column :spree_shipping_methods, :display_order
    remove_column :spree_state_events, :stateful_id
    remove_column :spree_state_events, :user_id
    remove_column :spree_state_events, :name
    remove_column :spree_state_events, :created_at
    remove_column :spree_state_events, :updated_at
    remove_column :spree_state_events, :previous_state
    remove_column :spree_state_events, :stateful_type
    remove_column :spree_state_events, :next_state
    change_column :spree_tax_categories, :created_at, :datetime, null: false
    change_column :spree_tax_categories, :updated_at, :datetime, null: false
    change_column :spree_tax_rates, :amount, :decimal, precision: '8', scale: '5'
    change_column :spree_tax_rates, :created_at, :datetime, null: false
    change_column :spree_tax_rates, :updated_at, :datetime, null: false
    change_column :spree_taxonomies, :created_at, :datetime, null: false
    change_column :spree_taxonomies, :updated_at, :datetime, null: false
    remove_column :spree_taxonomies, :sort_order
    change_column :spree_taxons, :taxonomy_id, :integer
    change_column :spree_taxons, :created_at, :datetime, null: false
    change_column :spree_taxons, :updated_at, :datetime, null: false
    remove_column :spree_taxons, :instructions
    change_column :spree_tokenized_permissions, :created_at, :datetime, null: false
    change_column :spree_tokenized_permissions, :updated_at, :datetime, null: false
    change_column :spree_trackers, :created_at, :datetime, null: false
    change_column :spree_trackers, :updated_at, :datetime, null: false
    change_column :spree_users, :encrypted_password, :string, limit: '128'
    change_column :spree_users, :password_salt, :string, limit: '128'
    change_column :spree_users, :created_at, :datetime, null: false
    change_column :spree_users, :updated_at, :datetime, null: false
    change_column :spree_variants, :count_on_hand, :integer, default: '0'
    remove_column :spree_variants, :price
    remove_column :spree_variants, :stock_type
    remove_column :spree_variants, :background_shade
    change_column :spree_zone_members, :created_at, :datetime, null: false
    change_column :spree_zone_members, :updated_at, :datetime, null: false
    change_column :spree_zones, :created_at, :datetime, null: false
    change_column :spree_zones, :updated_at, :datetime, null: false
    remove_index :spree_adjustments, column: [:order_id]
    remove_index :delayed_jobs, column: [:priority, :run_at]
    remove_index :gift_cards, column: [:number]
    remove_index :spree_option_values, column: [:option_type_id]
    remove_index :spree_option_values_variants, [:variant_id, :option_value_id]
    add_index :spree_option_values_variants, [:variant_id], name: 'index_spree_option_values_variants_on_variant_id'
    remove_index :spree_option_values_variants, [:variant_id]
    add_index :spree_option_values_variants, [:variant_id, :option_value_id], name: 'index_option_values_variants_on_variant_id_and_option_value_id'
    remove_index :spree_preferences, column: [:owner_id, :owner_type, :name, :group_id, :group_type]
    remove_index :spree_product_groups, column: [:name]
    remove_index :spree_product_groups, column: [:permalink]
    remove_index :spree_product_scopes, column: [:name]
    remove_index :spree_product_scopes, column: [:product_group_id]
    remove_index :sessions, column: [:session_id]
    remove_index :sessions, column: [:updated_at]
    remove_index :spree_users, column: [:persistence_token]
    remove_index :variants_promotion_rules, column: [:promotion_rule_id]
    remove_index :variants_promotion_rules, column: [:variant_id]
    remove_index :volume_prices, column: [:variant_id]
  end
end
