module ArDocStore
  module Attributes
    class Decimal < Base
      def predicate
        'number'
      end

      def type
        :number
      end

      def attribute_type
        ActiveModel::Type::Decimal
      end
    end
  end
end
