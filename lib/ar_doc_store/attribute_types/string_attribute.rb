module ArDocStore
  module AttributeTypes
    class StringAttribute < BaseAttribute
      def predicate
        'text'
      end

      def attribute_type
        ActiveModel::Type::String
      end
    end
  end
end
