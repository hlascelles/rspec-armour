# frozen_string_literal: true

module RSpec
  module Mocks
    module Matchers
      # This class is patched to prevent mocking ActiveRecord associations and finders.
      class Receive
        def self.patch_for_armour!
          # rubocop:disable ThreadSafety/ClassInstanceVariable
          @armour_patched ||= false
          return if @armour_patched

          @armour_patched = true
          # rubocop:enable ThreadSafety/ClassInstanceVariable

          %i[
            setup_expectation
            setup_negative_expectation
            setup_allowance
            setup_any_instance_expectation
            setup_any_instance_negative_expectation
            setup_any_instance_allowance
            matches?
            does_not_match?
          ].each do |method|
            next unless method_defined?(method)

            patch_method(method)
          end
        end

        def self.patch_method(method)
          original_method = instance_method(method)
          define_method(method) do |subject, &block|
            if ENV["RSPEC_ARMOUR_DEBUG"] == "true"
              puts "Checking RSpec::Armour '#{@message}' on #{subject}"
            end
            if RSpec::Armour::Checker.restricted?(subject, @message)
              message = "Mocking/stubbing ActiveRecord association or finder `#{@message}` " \
                        "on `#{subject.inspect}` is restricted by rspec-armour."
              raise RSpec::Armour::MockError, message
            end
            original_method.bind_call(self, subject, &block)
          end
        end
      end
    end
  end
end
