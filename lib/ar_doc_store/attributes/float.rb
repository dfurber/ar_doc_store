module ArDocStore
  module Attributes
    class Float < Base
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
