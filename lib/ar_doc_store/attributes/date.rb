# frozen_string_literal: true

module ArDocStore
  module Attributes
    class Date < Base
      def define_query_method
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{attribute}?
            #{attribute}.present?
          end
        CODE
      end

      def type
        :date
      end

      def attribute_type
        ActiveRecord::Type::Date
      end
    end
  end
end
