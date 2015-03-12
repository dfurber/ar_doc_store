module ArDocStore

  module EmbeddableModel

    def self.included(mod)

      mod.send :include, ActiveModel::AttributeMethods
      mod.send :include, ActiveModel::Validations
      mod.send :include, ActiveModel::Conversion
      mod.send :extend,  ActiveModel::Naming
      mod.send :include, ActiveModel::Dirty
      mod.send :include, ActiveModel::Serialization
      mod.send :include, ArDocStore::Storage
      mod.send :include, ArDocStore::Embedding
      mod.send :include, InstanceMethods
      mod.send :extend, ClassMethods

      mod.class_eval do
        attr_accessor :_destroy
        attr_accessor :attributes, :parent

        class_attribute :virtual_attributes
        self.virtual_attributes ||= HashWithIndifferentAccess.new
        
        delegate :as_json, to: :attributes
        
        attribute :id, :uuid
      end

    end
    
    module InstanceMethods
      
      def initialize(attrs=HashWithIndifferentAccess.new)
        @attributes = HashWithIndifferentAccess.new
        self.parent = attrs.delete(:parent) if attrs
        apply_attributes attrs
        @_initialized = true
      end

      def apply_attributes(attrs=HashWithIndifferentAccess.new)
        virtual_attributes.keys.each do |attr|
          @attributes[attr] ||= nil
        end
        if attrs
          attrs.each { |key, value|
            key = "#{key}=".to_sym
            self.public_send(key, value) if methods.include?(key)
          }
        end
        self
      end
      
      def save
        parent && parent.save
      end

      def persisted?
        false
      end

      def inspect
        "#{self.class}: #{attributes.inspect}"
      end

      def read_store_attribute(store, key)
        @attributes[key]
      end

      def write_store_attribute(store, key, value)
        changed_attributes[key] = read_store_attribute(:data, key) if @_initialized
        @attributes[key] = value
      end

      def write_default_store_attribute(key, value)
        @attributes[key] = value
      end

      def data_will_change!
        true
      end
      
      def to_param
        id
      end
      
    end
    
    module ClassMethods
      
      def store_accessor(store, key)
        self.virtual_attributes ||= HashWithIndifferentAccess.new
        virtual_attributes[key] ||= true
        key = key.to_sym
        define_method key, -> { read_store_attribute(:data, key) }
        define_method "#{key}=".to_sym, -> (value) { write_store_attribute :data, key, value }
      end
      
    end

  end
end

