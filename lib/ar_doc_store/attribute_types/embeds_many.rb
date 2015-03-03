module ArDocStore
  module AttributeTypes

    class EmbedsManyAttribute < Base
      def build
        assn_name = attribute.to_sym
        class_name = options[:class_name] || attribute.to_s.classify
        model.store_accessor :data, assn_name
        create_embeds_many_accessors(assn_name, class_name)
        create_embeds_many_attributes_method(assn_name)
        create_embeds_many_validation(assn_name)
      end
      
      private

      def create_embeds_many_accessors(assn_name, class_name)
        model.class_eval do
          define_method assn_name.to_sym, -> {
            ivar = "@#{assn_name}"
            existing = instance_variable_get(ivar)
            return existing if existing
            my_class_name = class_name.constantize
            items = read_store_attribute(:data, assn_name)
            if items.present? && items.first.respond_to?(:keys)
              items = items.map { |item| my_class_name.new(item) }
            end
            items ||= []
            instance_variable_set ivar, (items)
            items
          }
          define_method "#{assn_name}=".to_sym, -> (values) {
            if values && values.respond_to?(:map)
              items = values.map { |item|
                my_class_name = class_name.constantize
                item.is_a?(my_class_name) ? item : my_class_name.new(item)
              }
            else
              items = []
            end
            instance_variable_set "@#{assn_name}", write_store_attribute(:data, assn_name, items)
            # data_will_change!
          }
          define_method "build_#{assn_name.to_s.singularize}", -> (attributes=nil) {
            assns = self.public_send assn_name
            item = class_name.constantize.new attributes
            assns << item
            public_send "#{assn_name}=", assns
            item
          }

          define_method "ensure_#{assn_name.to_s.singularize}", -> {
            public_send "build_#{assn_name.to_s.singularize}" if self.public_send(assn_name).blank?
          }
          # TODO: alias here instead of show the same code twice?
          define_method "ensure_#{assn_name}", -> {
            public_send "build_#{assn_name.to_s.singularize}" if self.public_send(assn_name).blank?
          }
        end
      end

      def create_embeds_many_attributes_method(assn_name)
        model.class_eval do
          define_method "#{assn_name}_attributes=", -> (values) {
            values = values && values.values || []
            models = public_send assn_name
            new_models = []
            values.each { |value| 
              value.symbolize_keys!
              if value.key?(:id)
                next if value.key?(:_destroy) && ArDocStore.convert_boolean(value[:_destroy])
                existing = models.detect { |item| item.id == value[:id] }
                if existing
                  new_models << existing.apply_attributes(value)
                else
                  # If there was an ID but we can't find it now, do we add it back or ignore it?
                  # Right now, add it back.
                  new_models << public_send("build_#{assn_name}", value)
                end
              else
                new_models << public_send("build_#{assn_name}", value)
              end
            }
            public_send "#{assn_name}=", new_models
            # values = values.reject { |item| item[:_destroy] && item[:_destroy].to_bool }
            # public_send "#{assn_name}=", values
          }
        end
      end

      def create_embeds_many_validation(assn_name)
        model.class_eval do
          validate_method = "validate_embedded_record_for_#{assn_name}"
          define_method validate_method, -> { validate_embeds_many assn_name }
          validate validate_method
        end        
      end
      

    end

  end
end
