require 'securerandom'

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
      mod.send :extend,  ClassMethods

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
        @_initialized = true
        initialize_attributes attrs
      end

      def instantiate(attrs=HashWithIndifferentAccess.new)
        initialize_attributes attrs
        # @changed_attributes = attributes
        @_initialized = true
        self
      end

      def initialize_attributes(attributes)
        @attributes = HashWithIndifferentAccess.new
        self.parent = attributes.delete(:parent) if attributes
        apply_attributes attributes
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
      
      def persisted?
        false
      end

      def inspect
        "#{self.class}: #{attributes.inspect}"
      end

      def read_store_attribute(store, attr)
        @attributes[attr]
      end

      def write_store_attribute(store, attribute, value)
        if @_initialized
          old_value = @attributes[attribute]
          if attribute.to_s != 'id' && value != old_value
            public_send :"#{attribute}_will_change!"
            parent.data_will_change! if parent
          end

        end
        @attributes[attribute] = value
      end

      def write_default_store_attribute(attr, value)
        @attributes[attr] = value
      end

      def to_param
        id
      end

      def id_will_change!
      end

    end
    
    module ClassMethods
      
      #:nodoc:
      def store_accessor(store, key)
        self.virtual_attributes ||= HashWithIndifferentAccess.new
        self.virtual_attributes = virtual_attributes.merge key =>  true
        key = key.to_sym
        define_method key, -> { read_store_attribute(:data, key) }
        define_method "#{key}=".to_sym, -> (value) { write_store_attribute :data, key, value }
      end

      def build(attrs=HashWithIndifferentAccess.new)
        if attrs.is_a?(self.class)
          attrs
        else
          instance = allocate
          instance.instantiate attrs
        end
      end


    end

  end
end

