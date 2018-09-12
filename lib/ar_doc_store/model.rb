module ArDocStore
  module Model
    def self.included(mod)
      mod.send :include, ArDocStore::Storage
      mod.send :include, ArDocStore::Embedding
      mod.send :include, InstanceMethods
      mod.after_initialize :assign_json_data
      # mod.before_save :mark_changed_embeds
    end

    module InstanceMethods
      def assign_json_data
        json_data = self[json_column]
        return if json_data.blank?
        json_attributes.keys.each do |key|
          next unless json_data.key?(key)
          send :attribute=, key, json_data[key]
          self[key].parent = self if self[key].respond_to?(:parent)
          self[key].embedded_as = key if self[key].respond_to?(:embedded_as)
          mutations_from_database.forget_change(key) unless new_record?
        end
      end
      # def mark_changed_embeds
      #   # puts changes.inspect
      #   json_attributes.each do |key, value|
      #     if value.respond_to?(:class_name) && !public_send(key).nil?
      #       puts public_send(key).changes.inspect
      #     end
      #   end
      # end
    end
  end
end
