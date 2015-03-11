module ArDocStore
  module AttributeTypes

    class BooleanAttribute < Base
      def build
        key = attribute.to_sym
        model.class_eval do
          store_accessor :data, key
          define_method "#{key}?".to_sym, -> { public_send(key) == true }
          define_method "#{key}=".to_sym, -> (value) {
            res = ArDocStore.convert_boolean(value)
            write_store_attribute(:data, key, res)
          }
          add_ransacker(key, 'bool')
        end
      end

      def type
        :boolean
      end

    end

  end
end
