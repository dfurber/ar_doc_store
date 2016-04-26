module ArDocStore
  module AttributeTypes

    class BooleanAttribute < BaseAttribute
      def build
        key = attribute.to_sym
        model.class_eval do
          store_accessor json_column, key
          define_method "#{key}?".to_sym, -> { public_send(key) == true }
          define_method "#{key}=".to_sym, -> (value) {
            res = ArDocStore.convert_boolean(value)
            write_store_attribute(json_column, key, res)
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
