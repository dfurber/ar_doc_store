# frozen_string_literal: true

module ArDocStore
  module Attributes
    class Array < Base
      def define_query_method
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{attribute}?
            #{attribute}.present?
          end
        CODE
      end

      def type
        :array
      end

      def attribute_type
        ActiveModel::Type::Value
      end

      def attribute_options
        { array: true }
      end
    end
  end
end
