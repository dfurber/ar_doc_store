module ArDocStore
  module AttributeTypes
    class IntegerAttribute < BaseAttribute
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
