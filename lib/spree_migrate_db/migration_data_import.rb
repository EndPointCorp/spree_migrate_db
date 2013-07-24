module SpreeMigrateDB
  class MigrationDataImport

    def self.run_import_file(mapping, import_file)
      md = new(mapping, import_file)
      md.run!
      md.stats
    end


    def initialize(mapping, import_file)
      @mapping = mapping[:tables]
      @import_file=import_file
      @row_count = 0
      @table_counts = {}
      @ar_tables = {}
      @errors = []
    end


    def run!
      @import_file.each_line do |line|
        @table_counts[line["table"]] ||= 0
        map = table_mapping(line["table"])
        new_field_map = remap(line, map)
        import new_field_map
        @row_count += 1
        @table_counts[line["table"]] += 1
        show_table_counts
        return false if @errors.size > 20
      end
    end

    def stats
      {
        :tables => @table_counts.keys.count,
        :indexes => 0,
        :rows => @row_count,
        :warnings => [],
        :errors => @errors.first(5),
        :seconds => 0.0
      }
    end

    private

    def show_table_counts
      output = ""
      @table_counts.each do |table, count|
        output << "#{table}... #{count}\n"
      end

      print output.chomp

    end

    def table_mapping(table_name)
      @mapping.detect {|map| map.export.name == table_name}
    end

    def remap(line, map)
      new_map = {:table => map.canonical_table_name, :row => {}}
      not_found = -> { :not_found }
      line["row"].each do |column, value| 
        col_map = map.export.fields.detect(not_found) {|f| f.column == column}
        if col_map == :not_found
          new_map[:row][column] = value
        else
          new_map[:row][col_map.column] = value 
        end
      end
      new_map
    end

    def import(field_map)
      table = field_map[:table]
      cols = field_map[:row].keys
      vals = field_map[:row].values
      result = insert_row(table, field_map[:row])
      #conn.execute insert_statement(table, cols,vals)
    end

    def conn
      @conn ||= ActiveRecord::Base.connection
    end

    def insert_row(table_name, row)
      ar = ar_table(table_name) 
      ar.create!(row)
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

    def insert_statement(table, cols, vals)
      cols.map!{|c| "'#{c}'"}
      vals.map!{|c| "'#{escape_single_quotes(c)}'"}
      "INSERT INTO #{table} (#{cols.join(',')}) VALUES (#{vals.join(',')})"
    end

    def escape_single_quotes(s) 
      return nil if s.nil?
      s.gsub(/'/, "\\\\'")
    end

  end
end
