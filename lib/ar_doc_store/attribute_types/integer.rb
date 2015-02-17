module ArDocStore
  module AttributeTypes

    class IntegerAttribute < Base
      def conversion
        :to_i
      end

      def predicate
        'int'
      end

      def type
        :integer
      end

    end

  end
end
