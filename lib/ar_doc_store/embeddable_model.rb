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
        attr_accessor :parent
        attr_reader :attributes

        class_attribute :virtual_attributes
        self.virtual_attributes ||= HashWithIndifferentAccess.new

        delegate :as_json, to: :attributes

        json_attribute :id, :uuid

        def self.attribute(name, *args)
          json_attribute name, *args
        end

      end

    end

    module InstanceMethods

      def initialize(attrs=HashWithIndifferentAccess.new)
        @_initialized = true
        initialize_attributes attrs
      end

      def instantiate(attrs=HashWithIndifferentAccess.new)
        initialize_attributes attrs
        @_initialized = true
        self
      end

      def initialize_attributes(attrs)
        @attributes ||= HashWithIndifferentAccess.new
        self.parent = attributes.delete(:parent) if attributes
        self.attributes = attrs
      end

      def attributes=(attrs=HashWithIndifferentAccess.new)
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
        !!read_store_attribute(nil, :id)
      end

      def inspect
        "#{self.class}: #{attributes.inspect}"
      end

      def read_store_attribute(store, attr)
        attributes[attr]
      end

      def write_store_attribute(store, attribute, value)
        if @_initialized
          old_value = attributes[attribute]
          if attribute.to_s != 'id' && value != old_value
            if Rails.version >= '5.2.0'
              set_attribute_was(attribute, old_value)
              mutations_from_database.force_change(attribute)
            else
              public_send :"#{attribute}_will_change!"
            end
            if parent
              parent.public_send("#{parent.json_column}_will_change!")
            end
          end
        end
        attributes[attribute] = value
      end

      def write_default_store_attribute(attr, value)
        attributes[attr] = value
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
        define_method key, -> { read_store_attribute(json_column, key) }
        define_method "#{key}=".to_sym, -> (value) { write_store_attribute json_column, key, value }
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
