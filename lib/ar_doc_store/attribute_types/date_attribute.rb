module ArDocStore
  module AttributeTypes
    class DateAttribute < BaseAttribute
      def build
        super
        attribute_name = attribute
        model.class_eval do
          define_method("#{attribute_name}?".to_sym) { send(:attribute, attribute_name).present? }
        end
      end

      def type
        :date
      end

      def attribute_type
        ActiveRecord::Type::Date
      end
    end
  end
end