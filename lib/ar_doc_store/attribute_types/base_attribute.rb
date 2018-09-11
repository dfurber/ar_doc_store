module ArDocStore
  module AttributeTypes
    class BaseAttribute
      attr_accessor :conversion, :predicate, :options, :model, :attribute, :default

      def self.build(model, attribute, options={})
        new(model, attribute, options).build
      end

      def initialize(model, attribute, options)
        @model, @attribute, @options = model, attribute, options
        @model.json_attributes[attribute] = self
        @default = options.delete(:default)
      end

      def build
        store_attribute
      end

      #:nodoc:
      def store_attribute
        attribute_name = @attribute
        predicate_method = predicate
        attribute_type = self.attribute_type
        options = attribute_options
        options.merge!(default: default) if default.present?
        model.class_eval do
          add_ransacker(attribute_name, predicate_method)
          attribute attribute_name, attribute_type.new, **options
          define_method "#{attribute_name}=".to_sym, -> (value) {
            value = nil if value == '' || value == ['']
            new_value = send :attribute=, attribute_name, value
            write_store_attribute(json_column, attribute_name, new_value)
            new_value
          }
        end
      end

      def attribute_type
        ActiveModel::Type::Value
      end

      def attribute_options
        {}
      end
    end
  end
end
