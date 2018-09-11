require 'securerandom'

module ArDocStore
  module AttributeTypes

    class UuidAttribute < BaseAttribute
      # def build
      #   key = attribute.to_sym
      #   model.class_eval do
      #     store_accessor json_column, key
      #     define_method key, -> {
      #       value = read_store_attribute(json_column, key)
      #       unless value
      #         value = SecureRandom.uuid
      #         write_store_attribute json_column, key, value
      #       end
      #       value
      #     }
      #     define_method "#{key}=".to_sym, -> (value) {
      #       write_store_attribute(json_column, key, value)
      #     }
      #     add_ransacker(key, 'text')
      #   end
      # end
      #

      def predicate
        'text'
      end

      def default
        -> { SecureRandom.uuid }
      end

      def attribute_type
        ActiveModel::Type::String
      end
    end

  end
end
