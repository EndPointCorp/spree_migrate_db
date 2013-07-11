module SpreeMigrateDB
  class UI
    def self.disable
      @disabled = true
    end

    def self.enable
      @disabled = false
    end

    def self.say(message)
      return if @disabled
      $stdout.puts message
    end

    def self.print(message)
      return if @disabled
      $stdout.print message
    end

    def self.ask(question, options=["y","n"], default=false)
      original_options = options.dup
      options.map! {|o| o[0].upcase }
      return options.first.upcase if @disabled

      print("#{question} #{optionify(original_options)} ")

      response = getchr.chr.upcase
      print("\n\r")

      if options.include? response
        return response
      elsif default && response.ord == 13 # Enter
        return default
      else
        ask(question, original_options)
      end
    end

    # Get a single character and return it without pressing return
    def self.getchr
      state = `stty -g`
      `stty raw -echo -icanon isig`

      # Allow for ctrl-c
      Signal.trap("INT") { exit }

      $stdin.getc.chr
    ensure
      `stty #{state}`
    end 

    def self.optionify(opts)
      m = opts.map do |o|
        o.to_s.gsub(/(.)(.+)/, '(\1)\2')
      end
      "[#{m.join("|")}]"
    end

    def self.map_menu(schema_diff)
      say "-"*70
      say " Spree DB Migration - Mapping ".center(70, "-")

      if schema_diff.has_saved_mapping?
        use_mapping = ask "Use previous mapping (#{schema_diff.saved_mapping_file})?"
        if use_mapping == "Y"
          schema_diff.load_mapping_from_file
          return schema_diff
        end
      end

      say "-"*70
      say " Table Mapping ".center(70, "-")
      say "-"*70
      schema_diff.mapping[:tables].each do |mt|
        mt.save_action ask(mt.as_question, mt.question_opts, :default)
      end

      say "-"*70
      say " Fields Mapping ".center(70, "-")
      say "-"*70
      schema_diff.mapping[:fields].each do |mf|
        mf.save_action ask(mf.as_question, mf.question_opts, :default)
      end

      say "-"*70
      say " Indexes Mapping ".center(70, "-")
      say "-"*70
      schema_diff.mapping[:indexes].each do |mf|
        mf.save_action ask(mf.as_question, mf.question_opts, :default)
      end

      say "-"*70
      save_mapping = ask("Save this mapping?")

      if save_mapping == "Y"
        schema_diff.save_mapping
        say "File saved to #{schema_diff.saved_mapping_file}"
      end

      say "Mapping completed."
      schema_diff
    end

    def self.start_migration?(header, stats)
      true
    end

    def self.display_stats(stats)
      say "-"*70
      say " Spree DB Migration ".center(70, "-")
      say "-"*70
      say "- Tables: #{stats[:tables]}".ljust(69, " ") + "-"
      say "- Indexes: #{stats[:indexes]}".ljust(69, " ") + "-"
      say "- Rows: #{stats[:rows]}".ljust(69, " ") + "-"
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

      if stats[:file_name]
        say " Generated Migration File ".center(70, "-")
        say "-"*70
        say stats[:file_name]
      end

      true
    end
  end
end
