require 'activerecord-import'
require "activerecord-import/base"
require 'pp'
module SpreeMigrateDB
  class ScrappyImport
    COMMIT_THRESHOLD = 10000
    DISPLAY_THRESHOLD = 2000

    INCLUDE_TABLES = %w[
      promotions
    ]
    #variants_promotion_rules

    # when loading the table specified as the key, also delete the tables in the array
    SIDE_POPULATED_TABLES = {
      :spree_variants => %w[ spree_prices ],
      :spree_calculators => %w[ spree_promotion_actions ],
      :spree_gift_cards => %w[ 
        spree_products
        spree_variants
        spree_option_types
        spree_option_values
        spree_option_values_variants
        spree_prices 
        spree_product_option_types
      ]
    }

    SKIP_TABLES = %w[ 
      product_imports 
      state_events ups_shipping_methods 
      variants_promotion_rules
      zip_code_ranges
    ]

    def initialize(import_file, clean=false)
      @import_file = MigrationFile.new import_file
      @ar_tables = {}
      @table_counts = {}
      @pending_table_rows = {}
      @errors = []
      @num_rows = 0
      @clean = clean
    end

    def import_tables(tables_list=INCLUDE_TABLES)
      canonical_tables_list = tables_list.map {|t| lookup_table_name(t)}
      delete_rows canonical_tables_list
      puts "Starting import..."

      unless tables_list.empty?
        puts "importing default data"
        default_data.each do |line|
          next unless tables_list.include? line["table"]
          import_data(line)
          break if @errors.count >= 5
        end

        puts "importing file data"
        @import_file.each_line do |line|
          next unless tables_list.include? line["table"]
          import_data(line)
          break if @errors.count >= 5
        end

        puts "importing post import data"
        post_import_data.each do |line|
          next unless canonical_tables_list.include? line["table"]
          import_data(line)
        end
      end
      
      import_pending
      display_stats
      import_special_cases
      reset_sequences
      puts "---- ERRORS ----"
      puts @errors.join("\n")
      puts "Done. Imported #{@num_rows} rows with #{@errors.count} errors."
    end

    def import!
      puts "Starting import..."

      # remove default data
      default_data.each do |line|
        next if SKIP_TABLES.include? line["table"]
        delete_if_new line["table"]
        import_data(line)
        break if @errors.count >= 5
      end

      @import_file.each_line do |line|
        next if SKIP_TABLES.include? line["table"]
        delete_if_new line["table"]
        import_data(line)
        break if @errors.count >= 5
      end

      post_import_data.each do |line|
        next if SKIP_TABLES.include? line["table"]
        delete_if_new line["table"]
        import_data(line)
      end
      
      import_pending
      display_stats
      import_special_cases
      reset_sequences
      puts "---- ERRORS ----"
      puts @errors.join("\n")
      puts "Done. Imported #{@num_rows} rows with #{@errors.count} errors."
    end

    private

    def delete_if_new(table)
      @deleted_tables ||= []
      unless @deleted_tables.include? table
        delete_rows([lookup_table_name(table)])
        @deleted_tables << table
      end
    end

    def post_import_data
      @post_import_data ||= [
        {"table" => "shipping_categories", "row" => {"id" => 1, "name" => "Default"}},

        {"table" => "states", "row" => {"id" => 1, "name" => "U.S. Armed Forces - Americas", "abbr" => "AA", "country_id" => "214"}},
        {"table" => "states", "row" => {"id" => 2, "name" => "U.S. Armed Forces - Europe", "abbr"   => "AE", "country_id" => "214"}},
        {"table" => "states", "row" => {"id" => 3, "name" => "U.S. Armed Forces - Pacific", "abbr"  => "AP", "country_id" => "214"}},

        # Gift Card Product
        {"table" => "products", "row" => {
          "id"                => 5000,
          "name"              => "Gift Card",
          "description"       => "Gift Card product used for internal use only.",
          "available_on"      => nil,
          "deleted_at"        => nil,
          "permalink"         => "gift-card",
          "count_on_hand"     => 999999,
          "on_demand"         => false,
          "display_type"      => 2,
          "whatsnew"          => false,
          "short_description" => "",
          "instructions"      => "",
          "is_gift_card"      => true
        }},


        # Gift Card Option Type
        {"table" => "option_types", "row" => {"id" => 10, "name" => "Gift Card Price", "presentation" => "Gift Card Price"}},
        {"table" => "product_option_types", "row" => {"position" => 1, "product_id" => 5000, "option_type_id" => 10}},


        #Gift Card Option Values
        {"table" => "option_values", "row" => { "id" => 3000, "position" => 1, "name" => "amount_25",  "presentation"  => "25", "option_type_id"  => 10}},
        {"table" => "option_values", "row" => { "id" => 3001, "position" => 2, "name" => "amount_50",  "presentation"  => "50", "option_type_id"  => 10}},
        {"table" => "option_values", "row" => { "id" => 3002, "position" => 3, "name" => "amount_75",  "presentation"  => "75", "option_type_id"  => 10}},
        {"table" => "option_values", "row" => { "id" => 3003, "position" => 4, "name" => "amount_100", "presentation" => "100", "option_type_id" => 10}},
        {"table" => "option_values", "row" => { "id" => 3004, "position" => 5, "name" => "amount_150", "presentation" => "150", "option_type_id" => 10}},
        {"table" => "option_values", "row" => { "id" => 3005, "position" => 6, "name" => "amount_200", "presentation" => "200", "option_type_id" => 10}},
        {"table" => "option_values", "row" => { "id" => 3006, "position" => 7, "name" => "amount_250", "presentation" => "250", "option_type_id" => 10}},

        # Gift Card Variants
        {"table" => "variants", "row" => { "id" => 12999, "sku" => "gift-card-25",  "product_id" => 5000, "count_on_hand" => 999999, "position" => 1, "stock_type" => 2, "price" => "25.00", "is_master" => true}},
        {"table" => "variants", "row" => { "id" => 13000, "sku" => "gift-card-25",  "product_id" => 5000, "count_on_hand" => 999999, "position" => 1, "stock_type" => 2, "price" => "25.00"}},
        {"table" => "variants", "row" => { "id" => 13001, "sku" => "gift-card-50",  "product_id" => 5000, "count_on_hand" => 999999, "position" => 2, "stock_type" => 2, "price" => "50.00"}},
        {"table" => "variants", "row" => { "id" => 13002, "sku" => "gift-card-75",  "product_id" => 5000, "count_on_hand" => 999999, "position" => 3, "stock_type" => 2, "price" => "75.00"}},
        {"table" => "variants", "row" => { "id" => 13003, "sku" => "gift-card-100", "product_id" => 5000, "count_on_hand" => 999999, "position" => 4, "stock_type" => 2, "price" => "100.00"}},
        {"table" => "variants", "row" => { "id" => 13004, "sku" => "gift-card-150", "product_id" => 5000, "count_on_hand" => 999999, "position" => 5, "stock_type" => 2, "price" => "150.00"}},
        {"table" => "variants", "row" => { "id" => 13005, "sku" => "gift-card-200", "product_id" => 5000, "count_on_hand" => 999999, "position" => 6, "stock_type" => 2, "price" => "200.00"}},
        {"table" => "variants", "row" => { "id" => 13006, "sku" => "gift-card-250", "product_id" => 5000, "count_on_hand" => 999999, "position" => 7, "stock_type" => 2, "price" => "250.00"}},

        # Gift Card Option Values Variants
        {"table" => "option_values_variants", "row" => { "variant_id" => 13000, "option_value_id" => 3000 }},
        {"table" => "option_values_variants", "row" => { "variant_id" => 13001, "option_value_id" => 3001 }},
        {"table" => "option_values_variants", "row" => { "variant_id" => 13002, "option_value_id" => 3002 }},
        {"table" => "option_values_variants", "row" => { "variant_id" => 13003, "option_value_id" => 3003 }},
        {"table" => "option_values_variants", "row" => { "variant_id" => 13004, "option_value_id" => 3004 }},
        {"table" => "option_values_variants", "row" => { "variant_id" => 13005, "option_value_id" => 3005 }},
        {"table" => "option_values_variants", "row" => { "variant_id" => 13006, "option_value_id" => 3006 }},

        # Zip Code Ranges
        {"table" => "spree_zip_code_ranges", "row" => { "id" => 1, "name" => "New York City", "start_zip" => "10001", "end_zip" => "10292" }},
        {"table" => "spree_zip_code_ranges", "row" => { "id" => 2, "name" => "Bronx", "start_zip" => "10451", "end_zip" => "10499" }},
        {"table" => "spree_zip_code_ranges", "row" => { "id" => 3, "name" => "Queens", "start_zip" => "11001", "end_zip" => "11697" }},
        {"table" => "spree_zip_code_ranges", "row" => { "id" => 4, "name" => "Manhattan", "start_zip" => "10001", "end_zip" => "10292" }},
        {"table" => "spree_zip_code_ranges", "row" => { "id" => 5, "name" => "Brooklyn", "start_zip" => "11201", "end_zip" => "11256" }},
      
      ]
    end

    def default_data
      @default_data ||= [ ]
    end

    def reset_sequences
      @table_counts.keys.each do |table|
        begin
          puts "Resetting sequence for #{table}"
          ar = ar_table(table)
          ar.reset_pk_sequence
        rescue => e
          @errors << e.message
        end
      end

    end

    def delete_rows(tables_list)
      delete_tables = add_side_tables_to_list(tables_list)
      delete_tables.each do |table|
        puts "Removing rows from #{table}"
        ar = ar_table(table)
        ar.delete_all
      end
    end

    def add_side_tables_to_list(tables_list)
      additional = []
      tables_list.each do |table_name|
        side_tables = SIDE_POPULATED_TABLES.fetch(table_name.to_sym) { :not_found }
        additional << side_tables unless side_tables == :not_found
      end
      return tables_list | (additional.flatten.uniq)
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

      fix_images
    end

    def fix_images
      return if %W[spree_assets spree_products spree_variants] - @table_counts.keys == 0
      puts "Fixing images..."
      asset = ar_table("spree_assets")
      product = ar_table("spree_products")
      variant = ar_table("spree_variants")

      invalid_assets = asset.where(:viewable_type => "Spree::Product", :type => "Spree::Image")
      invalid_assets.each do |a|
        v = variant.where(:product_id => a.viewable_id, :is_master => true).first
        a.viewable = v
        a.viewable_type = "Spree::Variant"
        a.save!
      end
    end

    def remaps
      @remaps ||= {
        "spree_activators"               => -> row { remap_activators(row) },
        "spree_addresses"                => -> row { row },
        "spree_adjustments"              => -> row { remap_adjustments(row) },
        "spree_assets"                   => -> row { remap_assets(row) },
        "spree_calculators"              => -> row { remap_calculators(row) },
        "spree_configurations"           => -> row { remap_configurations(row) },
        "spree_countries"                => -> row { remap_countries(row) },
        "spree_credit_cards"             => -> row { row },
        "spree_gift_cards"               => -> row { remap_gift_cards(row) },
        "spree_inventory_units"          => -> row { row },
        "spree_line_items"               => -> row { remap_line_items(row) },
        "spree_log_entries"              => -> row { remap_log_entries(row) },
        "spree_mail_methods"             => -> row { row },
        "spree_option_types"             => -> row { row },
        "spree_option_values"            => -> row { remap_option_values(row) },
        "spree_option_values_variants"   => -> row { row },
        "spree_orders"                   => -> row { remap_orders(row) },
        "spree_payment_methods"          => -> row { remap_payment_methods(row) },
        "spree_payments"                 => -> row { remap_payments(row) },
        "spree_preferences"              => -> row { remap_preferences(row) },
        "spree_prices"                   => -> row { row },
        "spree_product_groups"           => -> row { row },
        "spree_product_groups_products"  => -> row { row },
        "spree_product_option_types"     => -> row { remap_product_option_types(row) },
        "spree_product_properties"       => -> row { row },
        "spree_products_promotion_rules" => -> row { remap_products_promotion_rules(row) },
        "spree_products_taxons"          => -> row { remap_products_taxons(row) },
        "spree_products"                 => -> row { remap_products(row) },
        "spree_promotion_actions"        => -> row { row },
        "spree_promotion_rules"          => -> row { remap_promotion_rules(row) },
        "spree_properties"               => -> row { row },
        "spree_roles"                    => -> row { row },
        "spree_roles_users"              => -> row { row },
        "spree_shipments"                => -> row { remap_shipments(row) },
        "spree_shipping_categories"      => -> row { row },
        "spree_shipping_methods"         => -> row { remap_shipping_methods(row) },
        "spree_states"                   => -> row { remap_states(row) },
        "spree_tax_categories"           => -> row { row },
        "spree_tax_rates"                => -> row { remap_tax_rates(row) },
        "spree_taxonomies"               => -> row { row },
        "spree_taxons"                   => -> row { row },
        "spree_tokenized_permissions"    => -> row { row },
        "spree_trackers"                 => -> row { row },
        "spree_users"                    => -> row { row },
        "spree_variants"                 => -> row { remap_variants(row) },
        "spree_volume_prices"            => -> row { remap_volume_prices(row) },
        "spree_zip_code_ranges"          => -> row { remap_zip_code_ranges(row) },
        "spree_zone_members"             => -> row { remap_zone_members(row) },
        "spree_zones"                    => -> row { remap_zones(row) },
      }
    end

    def import_data(data)
      table = lookup_table_name(data["table"])
      row = data["row"]
      new_row = remaps.fetch(table).call(row)
      insert_row(table, new_row)
      display_stats if @num_rows % DISPLAY_THRESHOLD == 0
      import_pending if @num_rows % COMMIT_THRESHOLD == 0
    rescue KeyError => ke
      pp "No mapping found for #{data["table"]}"
      pp data["row"]
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
        @errors << "WARNING: #{table} is not canonical"
        ap "WARNING: #{table} is not canonical"
        table
      else
        c_table
      end
    end

    def canonical_lookup
      @canonical_lookup ||= CanonicalSpree::Lookup.new("1.3.0-stable")
    end

    def insert_row(table_name, row)
      return if row == :skip
      @table_counts[table_name] ||= 0
      @pending_table_rows[table_name] ||= []
      ar = ar_table(table_name) 
      @pending_table_rows[table_name] <<  ar.new(row, :without_protection => true)
      @num_rows += 1
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
      new_row = update_namespace(row, "type")
      new_row = update_namespace(new_row, "viewable_type")
      new_row["attachment_file_size"] = new_row.delete("attachment_size")
      if new_row["attachment_file_name"].blank?
        @errors << {:message => "Empty attachment", :table => "spree_assets", :row => new_row}
        return :skip
      end
      new_row
    end

    def remap_calculators(row)
      ignored_calculators = %w[
        Calculator::GiftCardDiscount 
        Calculator::DiscountOnlyMatchingItems
      ]

      ok_calculators = %w[
        Calculator::Ups::ThreeDaySelect
        Calculator::Ups::SecondDayAir
        Calculator::Ups::NextDayAir
        Calculator::Ups::Ground
        Calculator::Messenger 
        Calculator::NewYorkStateClothingSalesTax
        Calculator::FlatRate
        Calculator::PerItem
      ]
      return :skip if ignored_calculators.include? row["type"]

      if row["calculable_type"] == "Promotion"
        @promo_count ||= 1

        new_row = update_namespace(row, "type")
        new_row["calculable_id"] = @promo_count
        new_row["calculable_type"] = "Spree::PromotionAction"


        post_import_data << {
          "table" => "spree_promotion_actions", 
          "row" => {
            "id" => @promo_count, 
            "activator_id" => row["calculable_id"], 
            "position" => nil, 
            "type" => "Spree::Promotion::Actions::CreateAdjustment" 
          }

        }

        @promo_count += 1
        new_row
      elsif row["type"] == "Calculator::SalesTax"
        new_row = row.dup
        new_row["type"] = "Spree::Calculator::DefaultTax"
        new_row = update_namespace(new_row, "calculable_type")
        new_row 
      else
        if ok_calculators.include? row["type"]
          new_row = row.dup
          new_row = update_namespace(new_row, "type")
          new_row = update_namespace(new_row, "calculable_type")
          new_row 
        else
          @errors << {:message => "Invalid Calculator", :table => "spree_calculators", :row => row}
          :skip
        end
      end
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

      new_row.delete("credit_total")

      new_row
    end

    def remap_products(row)
      new_row = row.dup
      new_row["on_demand"] = false
      new_row["shipping_category_id"] = 1
      new_row
    end

    def remap_shipments(row)
      new_row = row.dup
      new_row
    end

    def remap_shipping_methods(row)
      new_row = row.dup
      new_row["shipping_category_id"] = 1
      new_row["match_all"] = true
      # make the In store pick up available to all North America
      if row["name"] == "In Store Pick Up"
        new_row["zone_id"] = 2
      end
      new_row
    end

    def remap_variants(row)
      new_row = row.dup
      post_import_data << {
        "table" => "spree_prices", 
        "row" => {"variant_id" => row["id"], "amount" => row["price"], "currency" => "USD"}
      }

      new_row.delete("price")

      new_row
    end

    def remap_payment_methods(row)
      update_namespace(row, "type")
    end

    def remap_payments(row)
      new_row = row.dup
      if row["source_type"] == "Creditcard"
        new_row["source_type"] = "Spree::CreditCard"
      end

      new_row
    end

    def remap_products_taxons(row)
      new_row = row.dup
      new_row.delete("created_at")
      new_row.delete("updated_at")
      new_row

    end

    def remap_volume_prices(row)
      new_row = row.dup
      range = row["range"]
      # current ranges are all single number values:
      # ["1", "12", "25", "50", "72", "100"]
      # The new version of spree_volume_pricing doesn't support this
      # so we are assuming that the range should be (NUM+), i.e. (12+)
      new_row["range"] = "(#{range}+)" unless range.blank?
      new_row["name"] = new_row.delete("display")
      new_row["discount_type"] = "price"
      new_row
    end

    def remap_states(row)
      new_row = row.dup
      stripped_state = row["name"].gsub(/\w\w\s-\s/, "")
      new_row["name"] = stripped_state
      new_row
    end

    def remap_zone_members(row)
      return :skip if row["zoneable_type"] == "Zone"
      update_namespace(row, "zoneable_type")
    end

    def remap_zones(row)
      row
    end

    def remap_gift_cards(row)
      @imported_gift_codes ||= []
      return :skip if row["balance"] == "0.00"
      return :skip if @imported_gift_codes.include? row["number"]

      balance = row["balance"].to_f
      variant_info = case 
                     when balance <= 25  then [25,  3000]
                     when balance <= 50  then [50,  3001]
                     when balance <= 75  then [75,  3002]
                     when balance <= 100 then [100, 3003]
                     when balance <= 150 then [150, 3004]
                     when balance <= 200 then [200, 3005]
                     when balance <= 250 then [250, 3006]
      end
      new_row = {
        "variant_id" => variant_info.last,
        "email" => "n_a@example.com",
        "name" => "N/A",
        "code" => row["number"],
        "note" => "Imported gift card number",
        "created_at" => row["created_at"],
        "updated_at" => row["balance_updated_at"],
        "current_value" => row["balance"],
        "original_value" => variant_info.first.to_s
      }
      @imported_gift_codes << row["number"]

      new_row
    end

    def remap_product_option_types(row)
      # Occasionally a row gets malformed. Not sure why
      if row["id"].blank?
        @errors << "Invalid product_option_types row: #{row.inspect}"
        return :skip 
      end

      row
    end

    def remap_zip_code_ranges(row)
      row
    end

    def remap_tax_rates(row)
      new_row = row.dup
      new_row["amount"] = row["amount"].to_f / 100

      new_row
    end

    def remap_activators(row)
      new_row = row.dup
      new_row["code"] = row["code"].downcase.strip
      new_row["event_name"] = "spree.checkout.coupon_code_added"
      new_row["type"] = "Spree::Promotion"
      new_row["advertise"] = !!row["promote"]
      new_row.delete("combine")
      new_row.delete("promote")
      new_row
    end

    def remap_promotion_rules(row)
      new_row = row.dup
      new_row["activator_id"] = new_row.delete("promotion_id")
      update_namespace(new_row, "type")
    end

    def remap_preferences(row)
      return :skip unless row["owner_type"] == "Calculator"
      new_row = row.merge({
        "key" => "spree/calculator/#{row["name"]}/amount/#{row["owner_id"]}",
        "value_type" => "decimal"
      })
      new_row.delete("group_id")
      new_row.delete("group_type")
      new_row.delete("name")
      new_row.delete("owner_id")
      new_row.delete("owner_type")
      new_row
    end

    def remap_products_promotion_rules(row)
      # New spree promotions only lets you have one promotion per product so we have to skip duplicates
      @promo_products ||= []
      return :skip if @promo_products.include? row["product_id"]

      @promo_products << row["product_id"]
      row

    end

  end
end
