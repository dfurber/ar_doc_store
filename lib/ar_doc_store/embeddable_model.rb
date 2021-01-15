# frozen_string_literal: true

require 'securerandom'

module ArDocStore
  module EmbeddableModel
    def self.included(mod)
      mod.send :include, ActiveModel::Model
      mod.send :include, ActiveModel::Attributes
      mod.send :include, ActiveModel::AttributeMethods
      mod.send :include, ActiveModel::Dirty
      mod.send :include, ActiveModel::Serialization
      mod.send :include, ArDocStore::Storage
      mod.send :include, ArDocStore::Embedding
      mod.send :include, ActiveSupport::Callbacks
      mod.send :include, InstanceMethods
      mod.send :extend,  ClassMethods

      mod.class_eval do
        define_callbacks :persist
        attr_accessor :_destroy
        attr_accessor :parent
        attr_accessor :embedded_as

        class_attribute :json_attributes
        self.json_attributes = HashWithIndifferentAccess.new

        json_attribute :id, :string #, default: -> { SecureRandom.uuid }

        set_callback :persist, :before, :ensure_id
        set_callback :persist, :after, :mark_embeds_as_persisted
      end
    end

    module InstanceMethods
      def initialize(values={})
        super(values)
        values && persisted? && values.keys.each do |key|
          mutations_from_database.forget_change(key)
        end
      end

      def embedded?
        true
      end

      def persist
        run_callbacks :persist
      end

      def ensure_id
        self.id ||= SecureRandom.uuid
      end

      def mark_embeds_as_persisted
        json_attributes.values.each do |value|
          if value.respond_to?(:embedded?) && value.embedded? && respond_to?(value.attribute) && !public_send(value.attribute).nil?
            public_send(value.attribute).persist
          end
        end
      end

      def new_record?
        id.blank?
      end

      def persisted?
        id.present?
      end

      def inspect
        "#{self.class}: #{attributes.inspect}"
      end

      def read_store_attribute(store, attr)
        attributes[attr.to_s]
      end

      def write_store_attribute(store, attribute, value)
        if parent
          if parent.is_a?(EmbeddedCollection)
            parent.save
          else
            parent.send :write_store_attribute, store, embedded_as, as_json
          end
        end
        value
      end

      def to_param
        id
      end

      def as_json(_=nil)
        attributes.inject({}) do |attrs, attr|
          attrs[attr[0]] = attr[1] unless attr[1].nil?
          attrs
        end
      end
    end

    module ClassMethods
      def build(attrs=HashWithIndifferentAccess.new, parent = nil)
        model = if attrs.is_a?(self.class)
                  attrs
                else
                  new(attrs)
                end
        model.parent = parent
        model
      end
    end
  end
end
