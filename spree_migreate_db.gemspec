# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree_migrate_db/version'

Gem::Specification.new do |spec|
  spec.name          = "spree_migrate_db"
  spec.version       = SpreeMigrateDB::VERSION
  spec.authors       = ["Mike Farmer"]
  spec.email         = ["mike.farmer@gmail.com"]
  spec.description   = %q{Migrate your Spree database from one version to another.}
  spec.summary       = %q{Spree tool to migrate a database from one version of Spree to another.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_dependency "rake"
  spec.add_dependency "activerecord-import"
end
