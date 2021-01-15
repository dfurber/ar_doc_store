# frozen_string_literal: true

module ArDocStore
  module Types
    class EmbedsMany < ActiveModel::Type::Value
      attr_accessor :class_name

      def initialize(class_name)
        @class_name = class_name
      end

      def cast(values)
        @class_name = @class_name.constantize if class_name.respond_to?(:constantize)
        collection = EmbeddedCollection.new
        values && values.each do |value|
          collection << if value.nil?
                          value
                        elsif value.kind_of?(class_name)
                          value
                        elsif value.respond_to?(:to_hash)
                          class_name.new value
                        else
                          nil
                        end
        end
        collection
      end

      def serialize(values)
        return if values.nil?

        if values.respond_to?(:each)
          values.map { |value|
            if value.nil?
              nil
            elsif value.kind_of?(class_name)
              value.serializable_hash
            else
              cast(value).serializable_hash
            end
          }.compact
        end
      end

      def deserialize(value)
        cast(value)
      end

      def changed_in_place?(raw_old_value, new_value)
        serialize(new_value) != raw_old_value
      end
    end
  end
end
