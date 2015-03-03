module ArDocStore
  module AttributeTypes

    class EmbedsManyAttribute < Base
      def build
        assn_name = attribute.to_sym
        class_name = options[:class_name] || attribute.to_s.classify
        model.store_accessor :data, assn_name
        create_reader_for assn_name, class_name
        create_writer_for assn_name, class_name
        create_build_method_for assn_name, class_name
        create_ensure_method_for assn_name
        create_embeds_many_attributes_method(assn_name)
        create_embeds_many_validation(assn_name)
      end
      
      private
      
      def add_method(method, block)
        model.class_eval do
          define_method method, block
        end
      end
      
      def create_reader_for(assn_name, class_name)
        add_method assn_name.to_sym, -> {
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
      end
      def create_writer_for(assn_name, class_name)
        add_method "#{assn_name}=".to_sym, -> (values) {
          if values && values.respond_to?(:map)
            items = values.map { |item|
              my_class_name = class_name.constantize
              item.is_a?(my_class_name) ? item : my_class_name.new(item)
            }
          else
            items = []
          end
          instance_variable_set "@#{assn_name}", write_store_attribute(:data, assn_name, items)
        }
      end
      
      def create_build_method_for(assn_name, class_name)
        add_method "build_#{assn_name.to_s.singularize}", -> (attributes=nil) {
          assns = self.public_send assn_name
          item = class_name.constantize.new attributes
          assns << item
          public_send "#{assn_name}=", assns
          item
        }
      end
      
      def create_ensure_method_for(assn_name)
        method = -> { public_send "build_#{assn_name.to_s.singularize}" if self.public_send(assn_name).blank? }
        add_method "ensure_#{assn_name.to_s.singularize}", method
        add_method "ensure_#{assn_name}", method
      end

      def create_embeds_many_attributes_method(assn_name)
        add_method "#{assn_name}_attributes=", -> (values) {
          values = values && values.values || []
          models = public_send assn_name
          next_models = []
          values.each { |value| 
            value.symbolize_keys!
            if value.key?(:id)
              next if value.key?(:_destroy) && ArDocStore.convert_boolean(value[:_destroy])
              existing = models.detect { |item| item.id == value[:id] }
              next_models << existing && existing.apply_attributes(value) || public_send("build_#{assn_name}", value)
            else
              next_models << public_send("build_#{assn_name}", value)
            end
          }
          public_send "#{assn_name}=", next_models
        }
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
