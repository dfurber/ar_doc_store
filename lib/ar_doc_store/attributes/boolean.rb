module ArDocStore
  module Attributes
    class Boolean < Base
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
