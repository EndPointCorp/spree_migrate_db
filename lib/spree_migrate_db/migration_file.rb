module SpreeMigrateDB
    class MigrationFile
      class NoMigrationFileError < StandardError; end

      def initialize(import_file)
        @import_file = import_file
        @position = :not_set
        @header = {}
        @definition = SchemaDefinition.empty
        raise NoMigrationFileError.new "File does not exist: #{import_file}" unless File.exist? import_file
      end

      def header
        get_head if @header.empty? 
        @header
      end

      def definition
        get_head if @definition == SchemaDefinition.empty
        @definition
      end

      private

      def get_head
        Zlib::GzipReader.open(@import_file) do |gz|
          @header = parse_from_json(gz.readline)
          @definition = SchemaDefinition.from_hash parse_from_json(gz.readline)
        end
      end

      def parse_from_json(json)
        JSON.parse(json)
      end

      

    end
end
