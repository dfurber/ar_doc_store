module ArDocStore
  module AttributeTypes

    class FloatAttribute < Base
      def conversion
        :to_f
      end

      def predicate
        'float'
      end
    end

  end
end
