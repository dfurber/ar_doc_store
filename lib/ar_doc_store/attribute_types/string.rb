module ArDocStore
  module AttributeTypes
    
    class StringAttribute < Base
      def conversion
        :to_s
      end

      def predicate
        'text'
      end

    end

  end
end

