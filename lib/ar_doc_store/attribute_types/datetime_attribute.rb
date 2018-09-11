module ArDocStore
  module AttributeTypes
    class DatetimeAttribute < BaseAttribute
      def type
        :datetime
      end

      def attribute_type
        ActiveRecord::Type::DateTime
      end
    end
  end
end