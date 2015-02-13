module ArDocStore
  module AttributeTypes
    class Base
      attr_accessor :conversion, :predicate, :options, :model, :attribute

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
        model.columns_hash[attribute.to_s] = ActiveRecord::ConnectionAdapters::PostgreSQLColumn.new(attribute, nil, column_type)
      end

      def column_type
        ActiveRecord::Type::String.new
      end
    end

  end
end
