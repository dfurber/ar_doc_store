module ArDocStore
  module AttributeTypes

    class FloatAttribute < BaseAttribute
      def conversion
        :to_f
      end

      def predicate
        'float'
      end

      def type
        :number
      end

    end

  end
end
