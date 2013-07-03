module SpreeMigrateDB
  class UI
    def self.display_stats(stats)
      puts "-"*70
      puts " Spree DB Migration ".center(70, "-")
      puts "-"*70
      puts "- Tables: #{stats[:tables]}".ljust(69, " ") + "-"
      puts "- Indexes: #{stats[:indexes]}".ljust(69, " ") + "-"
      puts "- Rows Exported: #{stats[:rows]}".ljust(69, " ") + "-"
      puts "- Warnings: #{stats[:warnings].size}".ljust(69, " ") + "-"
      puts "- Errors: #{stats[:errors].size}".ljust(69, " ") + "-"
      puts "- Seconds to run: #{stats[:seconds].round}".ljust(69, " ") + "-"
      puts "-"*70
      if stats[:warnings].size > 0
        puts " Warnings ".center(70, "-")
        stats[:warnings].each {|w| puts w }
        puts "-"*70
      end
      if stats[:errors].size > 0
        puts " Errors ".center(70, "-")
        stats[:errors].each {|e| puts e }
        puts "-"*70
      end
      puts " Generated Migration File ".center(70, "-")
      puts "-"*70
      puts stats[:file_name]

      true
    end
  end
end
