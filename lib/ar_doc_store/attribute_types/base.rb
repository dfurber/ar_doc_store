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

      # The purpose of this was to simply make it help SimpleForm guess the correct input type. But it unleashes the furies of ActiveRecord so goodbye.
      def add_to_columns_hash
        model.columns_hash ||= HashWithIndifferentAccess.new
        model.columns_hash[attribute.to_s] = self
      end

      def type
        :string
      end

      def cast_type
        @cast_type ||= CastTypeDuck.new(type)
      end

    end

    class CastTypeDuck
      attr_accessor :type, :type_cast_from_database

      def initialize(type)
        @type = type
      end

      def type_cast_for_database(*args)
        # What to do here? I think nothing because we aren't putting this in a databas.
      end

    end

  end
end
