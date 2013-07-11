#!/usr/bin/env ruby

system "export no_rspec=true"

require_relative 'spec/spec_helper'

SpreeMigrateDB::UI.enable
SpreeMigrateDB::Runner.import("1.3.0", "spec/support/schema.rb", "spec/support/test_migration.stf")

