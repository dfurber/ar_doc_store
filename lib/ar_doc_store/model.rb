module ArDocStore
  
  module Model
    
    def self.included(mod)
      mod.send :include, ArDocStore::Storage
      mod.send :include, ArDocStore::Embedding
      mod.send :include, InstanceMethods
    end

    module InstanceMethods

      def write_store_attribute(store_attribute, key, value)
        public_send "#{key}_will_change!"
        super(store_attribute, key, value)
      end

      def write_default_store_attribute(key, default_value)
        data[key] = default_value
      end

    end
  end
end