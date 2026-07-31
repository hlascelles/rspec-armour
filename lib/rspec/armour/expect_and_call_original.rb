# frozen_string_literal: true

module RSpec
  module Armour
    class ExpectationProxy
      def initialize(expectation, target)
        @expectation = expectation
        @target = target
      end

      def and_call_original(...)
        @expectation.and_call_original(...)
        self
      end

      def and_return(*)
        cleanup
        raise MockError, "Cannot call and_return when using expect_receive_and_call_original"
      end

      def and_raise(*)
        cleanup
        raise MockError, "Cannot call and_raise when using expect_receive_and_call_original"
      end

      def and_throw(*)
        cleanup
        raise MockError, "Cannot call and_throw when using expect_receive_and_call_original"
      end

      def and_yield(*)
        cleanup
        raise MockError, "Cannot call and_yield when using expect_receive_and_call_original"
      end

      def method_missing(name, ...)
        if @expectation.respond_to?(name)
          res = @expectation.public_send(name, ...)
          res.equal?(@expectation) ? self : res
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        @expectation.respond_to?(name, include_private) || super
      end

      private def cleanup
        RSpec::Mocks.space.proxy_for(@target).reset if defined?(::RSpec::Mocks)
      end
    end

    module ExampleMethods
      def expect_receive_and_call_original(target, method_name)
        expectation = RSpec::Armour.without_restrictions do
          expect(target).to receive(method_name).and_call_original
        end
        ExpectationProxy.new(expectation, target)
      end
    end
  end
end
