module ArDocStore
  module Attributes
    class Datetime < Base
      def define_query_method
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{attribute}?
            #{attribute}.present?
          end
        CODE
      end

      def type
        :datetime
      end

      def attribute_type
        ActiveRecord::Type::DateTime
      end
    end
  end
end