# frozen_string_literal: true

module ArDocStore
  module Types
    class EmbedsOne < ActiveModel::Type::Value
      attr_accessor :class_name

      def initialize(class_name)
        @class_name = class_name
      end

      def cast(value)
        @class_name = @class_name.constantize if class_name.respond_to?(:constantize)
        return if value.nil?

        if value.kind_of?(class_name)
          value
        elsif value.respond_to?(:to_hash)
          class_name.new value
        end
      end

      def serialize(value)
        return if value.nil?

        if value.kind_of?(class_name)
          value.serializable_hash
        else
          cast(value).serializable_hash
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
