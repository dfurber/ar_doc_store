module ArDocStore
  module AttributeTypes
    class DatetimeAttribute < BaseAttribute
      def conversion
        :to_time
      end

      def predicate
        'timestamp'
      end

      def type
        :datetime
      end
    end
  end
end
