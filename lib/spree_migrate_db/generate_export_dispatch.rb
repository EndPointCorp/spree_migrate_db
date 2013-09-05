require 'zlib'
require 'active_record' 
module SpreeMigrateDB
  class GenerateExportDispatch
    SKIP_TABLES = %w[sessions]

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
      UI.say "Export started."

      Zlib::GzipWriter.open @file_name do |gz|
        gz.puts @header.to_json
        gz.puts @definition.to_json

        @definition.tables.keys.each do |table|
          if SKIP_TABLES.include? table.to_s
            puts "Skipping table #{table}"
            next
          end
          tabledef = @definition.tables[table]
          
          row_count = table_row_count(table)
          prefix = "\rExporting table #{table} (#{row_count} rows)..."

          i = 0
          UI.print("\rQuerying #{table} for #{row_count} rows...")
          table_rows(table).each do |r|
            write_row(gz, table, r)
            i += 1
            percent = "#{((i/row_count.to_f) * 100).round}% "
            UI.print "#{prefix} #{percent}"
          end

          UI.print "#{prefix} done.\n"

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
      gz.puts({table: table, row: row}.to_json)
      @total_row_count += 1
    rescue => e
      @warnings <<  "Invalid row for table '#{table}' for id #{row.id}. #{e.class} --  #{e.message}"
    end

    def conn
      @conn ||= SourceDatabase.connection
    end
    
    def table_row_count(table_name)
      result = conn.execute("SELECT count(*) AS c FROM #{table_name}")
      result.first["c"]
    end

    def table_rows(table_name)
      conn.execute("SELECT * FROM #{table_name}")
    end
    
  end
end
