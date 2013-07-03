require 'zlib'
module SpreeMigrateDB
  class GenerateExportDispatch

    def self.generate_migration_file(header, definition, destination_dir)
      export = new(header, definition, destination_dir)
      export.generate
      export.stats
    end

    def initialize(header, definition, destiniation_dir)
      @header = header
      @definition = definition
      @table_count = definition.tables.keys.size
      @index_count = definition.indexes.size
      @total_row_count = 0
      @errors = []
      @warnings = []
      @file_name = File.join(destiniation_dir, "#{definition.name.parameterize("_")}.stf")
    end
    

    def generate
      start_time = Time.now
      puts "Export started."

      Zlib::GzipWriter.open @file_name do |gz|
        gz.write @header.to_json
        gz.write @definition.to_json

        @definition.tables.keys.each do |table|
          tabledef = @definition.tables[table]
          ar_class = initialize_table_object(table)
          next unless ar_class
          table_row_count = ar_class.count
          prefix = "\rExporting table #{table} (#{table_row_count} rows)..."

          i = 0
          print("\rQuerying #{table} for #{table_row_count} rows...")
          ar_class.all.each do |r|
            write_row(gz, table, r)
            i += 1
            percent = "#{((i/table_row_count.to_f) * 100).round}% "
            print "#{prefix} #{percent}"
          end

          print "#{prefix} done.\n"

          #break if @total_row_count > 30000
        end

      end

      end_time = Time.now
      @seconds = end_time - start_time
      true
    end

    def stats
      {
        tables: @table_count, 
        indexes: @index_count, 
        rows: @total_row_count, 
        warnings: @warnings,
        errors: @errors, 
        file_name: @file_name, 
        seconds: @seconds
      } 
    end

    private

    def initialize_table_object(table_name)
      table_name.classify.constantize
    rescue NameError 
      @errors << "Could not find class for #{table_name}"
      false
    end

    def write_row(gz, table, row)
      gz.write({table: table, row: row}.to_json)
      @total_row_count += 1
    rescue => e
      @warnings <<  "Invalid row for table '#{table}' for id #{row.id}. #{e.class} --  #{e.message}"
    end
    
  end
end
