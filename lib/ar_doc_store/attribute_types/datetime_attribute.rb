module ArDocStore
  module AttributeTypes
    class DatetimeAttribute < BaseAttribute
      def type
        :datetime
      end

      def load
        :to_time
      end

      def dump
        :to_s
      end
    end
  end
end