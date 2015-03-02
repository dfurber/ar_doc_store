require 'securerandom'

module ArDocStore
  module AttributeTypes

    class UuidAttribute < Base
      def build
        key = attribute.to_sym
        model.class_eval do
          store_accessor :data, key
          define_method "#{key}?".to_sym, -> { !!key }
          define_method key, -> {
            value = read_store_attribute(:data, key)
            unless value
              value = SecureRandom.uuid
              write_store_attribute :data, key, value
            end
            value
          }
          define_method "#{key}=".to_sym, -> (value) {
            res = nil
            res = true if value == 'true' || value == true || value == '1' || value == 1
            res = false if value == 'false' || value == false || value == '0' || value == 0
            write_store_attribute(:data, key, res)
          }
          add_ransacker(key, 'text')
        end
      end

      def type
        :boolean
      end

    end

  end
end
