module ArDocStore
  module Attributes
    class Base
      include CallbackSupport

      attr_accessor :conversion, :predicate, :options, :model, :attribute, :default

      after_build :add_ransacker
      after_build :define_query_method

      def self.build(model, attribute, options={})
        new(model, attribute, options).build
      end

      def initialize(model, attribute, options)
        @model, @attribute, @options = model, attribute, options
        @default = options.delete(:default)
      end

      def build
        run_callbacks :build do
          store_attribute
        end
        self
      end

      #:nodoc:
      def store_attribute
        attribute_name = @attribute
        attribute_type = self.attribute_type
        options = attribute_options
        options.merge!(default: default) if default.present?
        model.class_eval do
          attribute attribute_name, attribute_type.new, **options
          define_method "#{attribute_name}=".to_sym, -> (value) {
            value = nil if value == '' || value == ['']
            send :attribute=, attribute_name, value
            new_value = send :attribute, attribute_name
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

      def embedded?
        false
      end

      def add_ransacker
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          add_ransacker :#{attribute}, "#{predicate}"
        CODE
      end

      def define_query_method
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{attribute}?
            !!#{attribute}
          end
        CODE
      end
    end
  end
end
