module ArDocStore
  module Attributes
    class String < Base
      def predicate
        'text'
      end

      def attribute_type
        ActiveModel::Type::String
      end
    end
  end
end
