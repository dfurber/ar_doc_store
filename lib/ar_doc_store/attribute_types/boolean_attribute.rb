module ArDocStore
  module AttributeTypes
    class BooleanAttribute < BaseAttribute
      def predicate
        'bool'
      end

      def type
        :boolean
      end

      def attribute_type
        ActiveModel::Type::Boolean
      end
    end
  end
end
