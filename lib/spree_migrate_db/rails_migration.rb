module SpreeMigrateDB
  class StandardMigration
    attr_reader :up, :down
    def initialize(map_item)
      @map_item = map_item
      @up = nil
      @down = nil
    end

    def self.generate(map_item)
      migration = new(map_item)
      migration.generate
      migration
    end

    private

    def options_string_hash(options)
      self.class.options_string_hash(options)
    end

    def self.options_string_hash(options)
      o = options.dup

      if (o && o.empty?) || o.nil?
        opts = ""
      else
        opt_strings = o.inject([]) {|new_o, (k,v)| new_o << "#{k}: #{quoted(v)}"}
        opts = ", #{opt_strings.join(", ")}"
      end
      opts
    end

    def quoted(value)
      self.class.quoted(value)
    end

    def self.quoted(value)
      if value.kind_of? TrueClass or value.kind_of? FalseClass
        return value.to_s
      else
        return "'#{value}'"
      end
    end

    def stringify_symbols_array(arr)
      a = arr.map { |e| ":#{e}" }
      "[#{a.join(", ")}]"
    end
  end

  class TableMigration < StandardMigration
    def generate
      return unless @map_item.action == :create

      if @map_item.options[:canonical].to_s == :not_canonical.to_s
        canonical_table_name = @map_item.export.name
      else
        canonical_table_name = @map_item.options[:canonical].to_s
      end

      migration = "create_table :#{canonical_table_name} do |t|"
      @map_item.export.fields.each do |f|
        migration << "\n      #{FieldMigration.column_migration(f)}"
      end
      migration << "\n    end"

      @up = migration
      @down = "drop_table :#{@map_item.export.name}"
    end

  end

  class FieldMigration < StandardMigration
    def self.column_migration(field_def)
      "t.#{field_def.type} :#{field_def.column}#{options_string_hash(field_def.options)}"
    end

    def generate
      case @map_item.action
      when :create then @up, @down = standalone(@map_item.export.options)
      when :update then @up, @down = update
      end
    end


    private

    def standalone(options)
      export = @map_item.export
      [
        "add_column :#{export.table}, :#{export.column}, :#{export.type}#{options_string_hash(options)}",
        "remove_column :#{export.table}, :#{export.column}"
      ]
    end

    def update
      [
        standalone(@map_item.options).first.gsub("add_column", "change_column"),
        standalone(@map_item.export.options).first.gsub("add_column", "change_column")
      ]
    end

  end

  class IndexMigration < StandardMigration

    def generate
      case @map_item.action
      when :create then @up, @down = create_index
      when :recreate then @up, @down = update_index
      end
    end


    private

    def create_index
      if @map_item.export.name
        index_options = @map_item.export.options.merge(:name => @map_item.export.name)
      else
        index_options = @map_item.export.options
      end
      cols = stringify_symbols_array(@map_item.export.fields)
      opts = options_string_hash(index_options)

      add_migration = "add_index :#{@map_item.canonical_table_name}, #{cols}#{opts}"
      remove_migration = "remove_index :#{@map_item.canonical_table_name}, column: #{cols}"

      [add_migration, remove_migration]
    end

    def update_index
      current_cols = stringify_symbols_array(@map_item.current.fields)
      export_cols = stringify_symbols_array(@map_item.export.fields)
      export_opts = options_string_hash(@map_item.export.options)

      if @map_item.current.name
        current_opts = options_string_hash(@map_item.current.options.merge(:name => @map_item.current.name))
      else
        current_opts = options_string_hash(@map_item.current.options)
      end

      up_remove_migration = "remove_index :#{@map_item.current.table}, #{current_cols}"
      up_add_migration = "add_index :#{@map_item.canonical_table_name}, #{export_cols}#{export_opts}"

      down_remove_migration = "remove_index :#{@map_item.canonical_table_name}, #{export_cols}"
      down_add_migration = "add_index :#{@map_item.current.table}, #{current_cols}#{current_opts}"


      [[up_remove_migration, up_add_migration], [down_remove_migration, down_add_migration]]
    end

  end

  RailsMigrationFile = Struct.new(:path, :body) do
    def save!
      filename = File.expand_path(path)
      File.open(filename, "w") do |f|
        f.puts body
      end
      UI.say "Migration file saved to: #{filename}"
    end
  end


  class RailsMigration
    attr_reader :up_changes, :down_changes, :rails_migration_file
    def initialize(mapping)
      @mapping = mapping.deep_symbolize_keys
      @mapping_list = Array(mapping[:tables]) + Array(mapping[:fields]) + Array(mapping[:indexes])
      @up_changes = {:tables => [], :fields => [], :indexes => []}
      @down_changes = {:tables => [], :fields => [], :indexes => []}
      @rails_migration_file = nil
    end

    def generate_migration_code
      @mapping_list.each do |map_item|
        if map_item.type == :table
          m = TableMigration.generate(map_item)
          @up_changes[:tables] << m.up if m.up
          @down_changes[:tables] << m.down if m.down
        elsif map_item.type == :field
          m = FieldMigration.generate(map_item)
          @up_changes[:fields] << m.up if m.up
          @down_changes[:fields] << m.down if m.down
        elsif map_item.type == :index
          m = IndexMigration.generate(map_item)
          @up_changes[:indexes] << m.up if m.up
          @down_changes[:indexes] << m.down if m.down
        else
          raise "Unknown map_item #{map_item.type}"
        end
      end
    end

    def generate_migration_file(migration_dir)
      if (up_code + down_code).empty?
        UI.say "No changes found."
        return
      end

      filename = File.join(migration_dir, "spree_upgrade.rb")

      filebody = <<-RUBY.chomp
class SpreeUpgrade < ActiveRecord::Migration
  def self.up
    #{up_code.join("\n    ")}
  end

  def self.down
    #{down_code.join("\n    ")}
  end
end
      RUBY

      @rails_migration_file = RailsMigrationFile.new(filename, filebody)
      @rails_migration_file.save!
    end

    def run!
      unless @rails_migration_file
        UI.say "Migrations did not run." 
        return
      end


      # do something
      #
    end


    private

    def up_code
      (@up_changes[:tables] + @up_changes[:fields] + @up_changes[:indexes]).flatten
    end

    def down_code
      (@down_changes[:tables] + @down_changes[:fields] + @down_changes[:indexes]).flatten
    end


  end
end
