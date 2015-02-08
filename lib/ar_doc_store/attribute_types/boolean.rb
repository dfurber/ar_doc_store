module ArDocStore
  module AttributeTypes

    class BooleanAttribute < Base
      def build
        key = attribute.to_sym
        model.class_eval do
          store_accessor :data, key
          # define_method key, -> { item = super(); item && item == true }
          define_method "#{key}?".to_sym, -> { !!key }
          define_method "#{key}=".to_sym, -> (value) {
            res = nil
            res = true if value == 'true' || value == true || value == '1' || value == 1
            res = false if value == 'false' || value == false || value == '0' || value == 0
            write_store_attribute(:data, key, res)
          }
          add_ransacker(key, 'bool')
        end
      end
    end

  end
end
