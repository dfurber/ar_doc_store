require 'securerandom'

module ArDocStore
  module AttributeTypes

    class UuidAttribute < BaseAttribute
      def build
        key = attribute.to_sym
        model.class_eval do
          store_accessor :data, key
          define_method key, -> {
            value = read_store_attribute(:data, key)
            unless value
              value = SecureRandom.uuid
              write_store_attribute :data, key, value
            end
            value
          }
          define_method "#{key}=".to_sym, -> (value) {
            write_store_attribute(:data, key, value)
          }
          add_ransacker(key, 'text')
        end
      end


    end

  end
end
