module ArDocStore
  module AttributeTypes

    class ArrayAttribute < BaseAttribute

      def store_attribute
        super
        attribute_name = attribute
        model.class_eval do
          define_method("#{attribute_name}?".to_sym) { send(:attribute, attribute_name).present? }
        end
      end

      def type
        :array
      end

      def attribute_type
        ActiveModel::Type::Value
      end

      def attribute_options
        { array: true }
      end

    end

  end
end
