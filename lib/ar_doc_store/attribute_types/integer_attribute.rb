module ArDocStore
  module AttributeTypes

    class IntegerAttribute < BaseAttribute
      def conversion
        :to_i
      end

      def predicate
        'int'
      end

      def type
        :number
      end

    end

  end
end
