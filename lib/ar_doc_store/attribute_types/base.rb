module ArDocStore
  module AttributeTypes
    class Base
      attr_accessor :conversion, :predicate, :options, :model, :attribute, :default

      def self.build(model, attribute, options={})
        new(model, attribute, options).build
      end

      def initialize(model, attribute, options)
        @model, @attribute, @options = model, attribute, options
        add_to_columns_hash
      end

      def build
        model.store_attributes conversion, predicate, attribute
      end

      def add_to_columns_hash
        model.columns_hash[attribute.to_s] = self
      end

      def type
        :string
      end

      def cast_type
        type
      end

    end

  end
end
