# frozen_string_literal: true

module ArDocStore
  module Attributes
    class Integer < Base
      def predicate
        'int'
      end

      def type
        :number
      end

      def attribute_type
        ActiveModel::Type::Integer
      end
    end
  end
end
