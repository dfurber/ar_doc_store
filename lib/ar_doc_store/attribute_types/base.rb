module ArDocStore
  module AttributeTypes
    class Base
      attr_accessor :conversion, :predicate, :options, :model, :attribute, :default

      def self.build(model, attribute, options={})
        new(model, attribute, options).build
      end

      def initialize(model, attribute, options)
        @model, @attribute, @options = model, attribute, options
      end

      def build
        model.store_attributes conversion, predicate, attribute
      end

    end

  end
end
