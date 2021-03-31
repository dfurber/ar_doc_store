# frozen_string_literal: true

module ArDocStore
  module Attributes
    class Enumeration < Base
      def build
        key = attribute.to_sym
        dictionary = options[:values]
        multiple = options[:multiple]
        strict = options[:strict]
        default_value = default
        model.class_eval do
          if multiple
            json_attribute key, as: :array, default: default_value
            if strict
              define_method "validate_#{key}" do
                value = public_send(key)
                errors.add(key, :invalid) if value.is_a?(Array) && value.present? && value.reject(&:blank?).detect {|d| !dictionary.include?(d)}
              end
              validate "validate_#{key}".to_sym
            end
          else
            json_attribute key, as: :string, default: default_value
            if strict
              validates_inclusion_of key, in: dictionary, allow_blank: true
            end
          end
          define_singleton_method "#{key}_choices" do
            dictionary
          end
          # if respond_to?(:ransacker)
          #   ransacker key do |parent|
          #     Arel.sql "#{parent.table[json_column].name}->'#{key}'"
          #   end
          # end
        end
      end

      def type
        :string
      end

      def add_ransacker
        raise 'hello'
      end
    end
  end
end
