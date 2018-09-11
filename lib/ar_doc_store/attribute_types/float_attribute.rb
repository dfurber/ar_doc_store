module ArDocStore
  module AttributeTypes
    class FloatAttribute < BaseAttribute
      def predicate
        'float'
      end

      def type
        :number
      end

      def attribute_type
        ActiveModel::Type::Float
      end
    end
  end
end
