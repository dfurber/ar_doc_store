module ArDocStore
  module AttributeTypes
    
    class StringAttribute < BaseAttribute
      def conversion
        :to_s
      end

      def predicate
        'text'
      end

    end

  end
end

