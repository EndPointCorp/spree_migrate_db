require 'activerecord-import'
require "activerecord-import/base"
module SpreeMigrateDB
  class ScrappyImport

    SKIP_TABLES = %w[ 
      gift_cards preferences product_groups product_groups_products product_imports 
      product_scopes product_taxons products products_promotion_rules promotion_rules
      promotions state_events taxonomies taxons ups_shipping_methods variants_promotion_rules
      volume_prices zip_code_ranges
    ]

    def initialize(import_file)
      @import_file = MigrationFile.new import_file
      @ar_tables = {}
      @table_counts = {}
      @pending_table_rows = {}
      @errors = []
      @num_rows = 0
    end

    def import!
      delete_rows

      @import_file.each_line do |line|
        next if SKIP_TABLES.include? line["table"]
        import_data(line)

        @num_rows += 1
        display_stats if @num_rows % 500 == 0
        import_pending if @num_rows % 5000 == 0
        break if @errors.count >= 10
      end
      import_pending
      display_stats
      import_special_cases
      
      puts "---- ERRORS ----"
      puts @errors.join("\n")
      puts "Done. Imported #{@num_rows} rows."
    end

    private

    def delete_rows
      remaps.keys.each do |table|
        puts "Removing rows for #{table}"
        ar = ar_table(table)
        ar.delete_all
      end

    end

    def import_pending
      @pending_table_rows.each do |table, rows|
        puts "Committing #{rows.count} rows for #{table}."
        ar = ar_table(table) 
        ar.import rows
      end
      @pending_table_rows = {}
    end

    def import_special_cases
      # TODO: Fix adjustments.adjustable_id and adjustable_type
      # Fix adjustments.eligable
    end

    def remaps
      @remaps ||= {
        "spree_addresses"              => lambda{ |row| row },
        "spree_adjustments"            => lambda{ |row| remap_adjustments(row) },
        "spree_assets"                 => lambda{ |row| remap_assets(row) },
        "spree_calculators"            => lambda{ |row| remap_calculators(row) },
        "spree_configurations"         => lambda{ |row| remap_configurations(row) },
        "spree_countries"              => lambda{ |row| remap_countries(row) },
        "spree_credit_cards"           => lambda{ |row| row },
        "spree_inventory_units"        => lambda{ |row| row },
        "spree_line_items"             => lambda{ |row| remap_line_items(row) },
        "spree_log_entries"            => lambda{ |row| remap_log_entries(row) },
        "spree_mail_methods"           => lambda{ |row| row },
        "spree_option_types"           => lambda{ |row| row },
        "spree_option_values"          => lambda{ |row| remap_option_values(row) },
        "spree_option_values_variants" => lambda{ |row| row },
        "spree_orders"                 => lambda{ |row| remap_orders(row) },
        "spree_payment_methods"        => lambda{ |row| row },
        "spree_payments"               => lambda{ |row| row },
        "spree_product_option_types"   => lambda{ |row| row },
        "spree_product_properties"     => lambda{ |row| row },
        "spree_products"               => lambda{ |row| remap_products(row) },
        "spree_properties"             => lambda{ |row| row },
        "spree_roles"                  => lambda{ |row| row },
        "spree_roles_users"            => lambda{ |row| row },
        "spree_shipments"              => lambda{ |row| remap_shipments(row) },
        "spree_shipping_methods"       => lambda{ |row| remap_shipping_methods(row) },
        "spree_states"                 => lambda{ |row| row },
        "spree_tax_categories"         => lambda{ |row| row },
        "spree_tax_rates"              => lambda{ |row| row },
        "spree_tokenized_permissions"  => lambda{ |row| row },
        "spree_trackers"               => lambda{ |row| row },
        "spree_users"                  => lambda{ |row| row },
        "spree_variants"               => lambda{ |row| remap_variants(row) },
        "spree_zone_members"           => lambda{ |row| row },
        "spree_zones"                  => lambda{ |row| row },
      }
    end

    def import_data(data)
      table = lookup_table_name(data["table"])
      row = data["row"]
      new_row = remaps.fetch(table).call(row)
      insert_row(table, new_row)
    rescue KeyError => ke
      ap "No mapping found for #{data["table"]}"
      ap data["row"]
      raise ke
    end

    def display_stats
      stats = ""
      @table_counts.each do |table, count|
        stats << "#{table}: #{count}\n"
      end
      system "clear && echo '#{stats}' "

    end

    def lookup_table_name(table)
      c_table = canonical_lookup.canonical_table_name(table)
      if c_table == :not_canonical
        table
      else
        c_table
      end
    end

    def canonical_lookup
      @canonical_lookup ||= CanonicalSpree::Lookup.new("1.3.0-stable")
    end

    def insert_row(table_name, row)
      @table_counts[table_name] ||= 0
      @pending_table_rows[table_name] ||= []
      ar = ar_table(table_name) 
      @pending_table_rows[table_name] <<  ar.new(row)
      @table_counts[table_name] += 1
    rescue => e
      @errors << {:message => e.message, :table => table_name, :row => row}
    end

    def ar_table(table_name)
      @ar_tables[table_name] ||= begin
                                   ar = Class.new(ActiveRecord::Base)
                                   ar.table_name = table_name
                                   ar
                                 end
    end

    def bool_or_nil(value)
      return true if value == "t"
      return false if value == "f"
      value
    end

    def update_namespace(row, field)
      new_row = row.dup
      new_row[field] = "Spree::#{new_row[field]}"
      new_row
    end

    def remap_adjustments(row)
      new_row = {
        "id"              => row["id"],
        "source_id"       => row["source_id"],
        "source_type"     => row["Spree::Order"],
        "adjustable_id"   => row["source_id"], # will be fixed after_import
        "adjustable_type" => row["Spree::Order"], # will be fixed after_import
        "originator_id"   => row["originator_id"],
        "originator_type" => row["originator_type"],
        "amount"          => row["amount"],
        "label"           => row["label"],
        "mandatory"       => bool_or_nil(row["mandatory"]),
        "locked"          => bool_or_nil(row["locked"]),
        "eligible"        => true,
        "created_at"      => row["created_at"],
        "updated_at"      => row["updated_at"]
      }

      new_row
    end

    def remap_assets(row)
      new_row = row.dup
      new_row["attachment_file_size"] = new_row.delete("attachment_size")
      new_row
    end

    def remap_calculators(row)
      update_namespace(row, "type")
    end

    def remap_configurations(row)
      update_namespace(row, "type")
    end

    def remap_countries(row)
      row["states_required"] = true
      row
    end

    def remap_line_items(row)
      row["currency"] = "USD"
      row
    end
    
    def remap_log_entries(row)
      update_namespace(row, "source_type")
    end

    def remap_option_values(row)
      new_row = row.dup
      new_row.delete("sku")
      new_row.delete("amount")
      new_row
    end

    def remap_orders(row)
      new_row = row.dup
      new_row["currency"] = "USD"
      new_row["last_ip_address"] = "127.0.0.1"

      # TODO: Add these to the table
      new_row.delete("is_broadway_customer")
      new_row.delete("accountnumber")
      new_row.delete("checked_subscribe_at")
      new_row.delete("add_to_mailing_list")
      new_row.delete("viewed_at")

      # TODO: figure out where these fields went
      new_row.delete("credit_total")
      new_row.delete("name")


      new_row
    end

    def remap_products(row)
      new_row = row.dup
      new_row["on_demand"] = false

      # TODO: Add these to the table
      #"display_type"
      #"short_description"
      #"instructions"
      #"whatsnew"
    end

    def remap_shipments(row)
      new_row = row.dup

      #TODO: add these to the table
      new_row.delete("fedex_account")

      new_row
    end

    def remap_shipping_methods(row)
      new_row = row.dup

      #TODO: Figure out these fields
      new_row.delete("hide_shipping_cost")
      new_row.delete("display_order")


      new_row

    end

    def remap_variants(row)
      new_row = row.dup

      #TODO: Fix these
      new_row.delete("price")
      new_row.delete("stock_type")
      new_row.delete("background_shade")

      new_row
    end

  end
end
