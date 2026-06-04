# frozen_string_literal: true

require "active_record"
require "active_support/core_ext/string/inflections"

module RSpec
  module Armour
    module Checker
      RESTRICTED_CLASS_METHODS = %i[
        find find_by find_by! where all first last count sum average minimum
        maximum pluck pick exists? create create! find_or_create_by
        find_or_create_by! find_or_initialize_by update update! destroy_all
        delete_all delete_by destroy_by first_or_create first_or_create!
        first_or_initialize
      ].freeze

      RESTRICTED_INSTANCE_METHODS = %i[
        save save! update update! update_attribute update_columns update_column
        destroy destroy! delete delete! touch reload increment! decrement!
        toggle!
      ].freeze

      DISABLED_KEY = :rspec_armour_disabled

      def self.restricted?(target, method_name)
        return false if disabled?

        method_sym = method_name.to_sym
        is_class, klass = resolve_target_info(target)

        return false unless klass.is_a?(Class) && klass < ::ActiveRecord::Base

        restricted_by_list?(is_class,
                            method_sym) || association_method_on_class?(klass, method_sym)
      end

      def self.resolve_target_info(target)
        if test_double?(target)
          resolve_double_info(target)
        else
          is_class = target.is_a?(Class)
          [is_class, is_class ? target : target.class]
        end
      end

      def self.test_double?(target)
        defined?(::RSpec::Mocks::TestDouble) && target.is_a?(::RSpec::Mocks::TestDouble)
      end

      def self.resolve_double_info(target)
        ref = target.instance_variable_get(:@doubled_module)
        return [false, nil] unless ref.respond_to?(:target)

        underlying_target = ref.target
        case target
        when ::RSpec::Mocks::InstanceVerifyingDouble
          [false, underlying_target]
        when ::RSpec::Mocks::ClassVerifyingDouble
          [true, underlying_target]
        when ::RSpec::Mocks::ObjectVerifyingDouble
          is_class = underlying_target.is_a?(Class)
          [is_class, is_class ? underlying_target : underlying_target.class]
        else
          [false, nil]
        end
      end

      def self.restricted_by_list?(is_class, method_sym)
        return true if RESTRICTED_INSTANCE_METHODS.include?(method_sym)

        is_class && RESTRICTED_CLASS_METHODS.include?(method_sym)
      end

      def self.association_method_on_class?(klass, method_name)
        return false unless klass.respond_to?(:reflections)

        reflections = klass.reflections
        reflections.any? do |name, _reflection|
          singular_name = name.to_s.singularize
          [
            name.to_sym,
            :"#{name}=",
            :"#{singular_name}_ids",
            :"#{singular_name}_ids=",
          ].include?(method_name)
        end
      end

      def self.disabled?
        Thread.current[DISABLED_KEY]
      end

      def self.disable!
        previous = Thread.current[DISABLED_KEY]
        Thread.current[DISABLED_KEY] = true
        yield
      ensure
        Thread.current[DISABLED_KEY] = previous
      end
    end
  end
end
