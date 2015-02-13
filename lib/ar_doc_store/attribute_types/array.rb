module ArDocStore
  module AttributeTypes
    
    class ArrayAttribute < Base

      def build
        key = attribute.to_sym
        model.class_eval do
          store_accessor :data, key
          define_method "#{key}=".to_sym, -> (value) {
            value = nil if value == ['']
            write_store_attribute(:data, key, value)
          }
          add_ransacker(key, 'text')
        end
      end

    end

  end
end

