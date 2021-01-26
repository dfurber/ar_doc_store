# frozen_string_literal: true

module ArDocStore
  module Model
    def self.included(mod)
      mod.send :include, ArDocStore::Storage
      mod.send :include, ArDocStore::Embedding
      mod.send :include, InstanceMethods
      mod.after_initialize :assign_json_data
      mod.before_validation :save_json_data
      mod.before_save :mark_embeds_as_persisted
    end

    module InstanceMethods
      def assign_json_data
        json_data = respond_to?(json_column) && self[json_column]
        json_data && json_attributes.keys.each do |key|
          next unless json_data.key?(key)
          self[key] = json_data[key] if respond_to?("#{key}=")
          # send :attribute=, key, json_data[key] if self.respond_to?("#{key}=")
          self[key].parent = self if self[key].respond_to?(:parent=)
          self[key].embedded_as = key if self[key].respond_to?(:embedded_as)
          mutations_from_database.forget_change(key) unless new_record?
        end
      end

      def save_json_data
        json_attributes.each do |key, value|
          write_store_attribute(json_column, key, read_attribute(key)) if changes.key?(key)
        end
      end

      def mark_embeds_as_persisted
        json_attributes.values.each do |value|
          if value.respond_to?(:embedded?) && value.embedded? && respond_to?(value.attribute)
            val = public_send(value.attribute)
            val.persist if val && val.respond_to?(:persist)
          end
        end
      end
    end
  end
end
