# frozen_string_literal: true

module ArDocStore
  module Attributes
    class EmbedsBase < Base
      attr_reader :class_name
      before_build :handle_options
      after_build :create_build_method
      after_build :create_ensure_method
      after_build :create_attributes_method
      after_build :create_validation

      def embedded?
        true
      end

      private

      def handle_options
        @class_name = options[:class_name] || attribute.to_s.classify
        @attribute = attribute.to_sym
      end

      def create_build_method
        # override in subclass
      end

      def create_ensure_method
        # override in subclass
      end

      def create_attributes_method
        # override in subclass
      end

      def create_validation
        # override in subclass
      end
    end
  end
end
