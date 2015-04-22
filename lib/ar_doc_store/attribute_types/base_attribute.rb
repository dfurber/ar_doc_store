module ArDocStore
  module AttributeTypes
    class BaseAttribute
      attr_accessor :conversion, :predicate, :options, :model, :attribute, :default

      def self.build(model, attribute, options={})
        new(model, attribute, options).build
      end

      def initialize(model, attribute, options)
        @model, @attribute, @options = model, attribute, options
        @model.virtual_attributes[attribute] = self
        @default = options.delete(:default)
      end

      def build
        model.store_attribute attribute, conversion, predicate, default
      end

    end

  end
end
