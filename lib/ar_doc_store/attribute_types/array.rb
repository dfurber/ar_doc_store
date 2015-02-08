module ArDocStore
  module AttributeTypes
    
    class ArrayAttribute < Base
      def conversion
        :to_a
      end

      def predicate
        'text'
      end

    end

  end
end

