module SpreeMigrateDB
  class InvalidSchemaDefinitionError < StandardError; end

  class GenerateSchemaDispatch
    class NoVersionFoundError < StandardError; end


    def self.get_definition(header)
      version = header.fetch(:spree_version) { :invalid_version }
      raise NoVersionFoundError.new "Header is invalid because it has no version" if version == :invalid_version

      definition = subscriptions.detect(->{:invalid_definition}) do |d|
        d.spree_version == version
      end

      raise NoVersionFoundError.new "There is no valid schema definition found for #{version}." if definition == :invalid_definition

      definition
    end

    def self.subscribe(definition)
      already_defined = subscriptions.detect do |d|
        d.spree_version == definition.spree_version
      end
      
      if already_defined
        UI.say "Skipping #{definition.to_s}. Already a schema definition subscribed for that version (#{already_defined.to_s})"
        already_defined
      else
        raise "Invalid" unless definition.respond_to? :to_hash
        subscriptions << definition
        definition
      end

    rescue => e
      raise InvalidSchemaDefinitionError.new "#{definition.to_s} does not support a subscribable interface"
    end

    def self.subscriptions
      @@subscriptions ||= []
    end

    def self.clear_subscriptions
      @@subscriptions = []
    end
     
  end
end
