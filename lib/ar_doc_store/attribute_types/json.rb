class ArDocStore::AttributeTypes::JsonAttribute < ArDocStore::AttributeTypes::Base

  def build
    key = attribute.to_sym
    default_value = default
    model.class_eval do
      store_accessor :data, key
      define_method key, -> {
        value = read_store_attribute(:data, key)
        value or default_value
      }
      define_method "#{key}=".to_sym, -> (value) {
        value = nil if value == ['']
        write_store_attribute(:data, key, value)
      }
      add_ransacker(key, 'jsonb')
    end
  end

end
