module SpreeMigrateDB
  class UI
    @@disabled = false

    def self.disable
      @@disabled = true
    end

    def self.say(message)
      return if @@disabled
      puts message
    end

    def self.display_stats(stats)
      say "-"*70
      say " Spree DB Migration ".center(70, "-")
      say "-"*70
      say "- Tables: #{stats[:tables]}".ljust(69, " ") + "-"
      say "- Indexes: #{stats[:indexes]}".ljust(69, " ") + "-"
      say "- Rows Exported: #{stats[:rows]}".ljust(69, " ") + "-"
      say "- Warnings: #{stats[:warnings].size}".ljust(69, " ") + "-"
      say "- Errors: #{stats[:errors].size}".ljust(69, " ") + "-"
      say "- Seconds to run: #{stats[:seconds].round}".ljust(69, " ") + "-"
      say "-"*70
      if stats[:warnings].size > 0
        say " Warnings ".center(70, "-")
        stats[:warnings].each {|w| say w }
        say "-"*70
      end
      if stats[:errors].size > 0
        say " Errors ".center(70, "-")
        stats[:errors].each {|e| say e }
        say "-"*70
      end
      say " Generated Migration File ".center(70, "-")
      say "-"*70
      say stats[:file_name]

      true
    end
  end
end
