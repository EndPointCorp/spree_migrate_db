require 'rspec/autorun'

DO_ISOLATION = ! defined?(Rails)

def isolate_from_rails(&block)
  return unless DO_ISOLATION
  block.call
end

isolate_from_rails do
  require 'awesome_print'
  require 'active_support/all'
  require 'ostruct'

  # swallow calls to Rails
  class ::Rails
    def self.root; File.expand_path("../", File.dirname(__FILE__)); end
    def self.method_missing(a,*b); self; end
  end

end

require_relative '../lib/spree_migrate_db'
