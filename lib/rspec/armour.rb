# frozen_string_literal: true

require "rspec"
require "rspec/mocks"
require_relative "armour/version"
require_relative "armour/checker"
require_relative "armour/receive_patch"
require_relative "armour/expect_and_call_original"

module RSpec
  module Armour
    class MockError < StandardError; end

    def self.without_restrictions(&)
      Checker.disable!(&)
    end
  end
end

# Ensure the matcher is loaded
require "rspec/mocks/matchers/receive"

RSpec::Mocks::Matchers::Receive.patch_for_armour!

RSpec.configure do |config|
  config.include RSpec::Armour::ExampleMethods

  config.around(:each, without_rspec_armour: true) do |example|
    RSpec::Armour.without_restrictions do
      example.run
    end
  end
end
