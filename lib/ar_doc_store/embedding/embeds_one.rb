module ArDocStore
  module Embedding
    module EmbedsOne
      
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end
    
      module InstanceMethods
      
        def validate_embeds_one(assn_name)
          record = public_send(assn_name)
          embed_valid?(assn_name, record) if record
        end

      end
    
      module ClassMethods

        def embeds_one(assn_name, *args)
          store_accessor :data, assn_name
          options = args.extract_options!
          class_name = options[:class_name] || assn_name.to_s.classify
          store_attribute_from_class class_name, assn_name
          create_embed_one_attributes_method(assn_name)
          create_embeds_one_accessors assn_name, class_name
          create_embeds_one_validation(assn_name)
        end

        private

        def create_embeds_one_accessors(assn_name, class_name)
          define_method "build_#{assn_name}", -> (attributes=nil) {
            class_name = class_name.constantize if class_name.respond_to?(:constantize)
            public_send "#{assn_name}=", class_name.new(attributes)
            public_send assn_name
          }
          define_method "ensure_#{assn_name}", -> {
            public_send "build_#{assn_name}" if public_send(assn_name).blank?
          }
        end

        def create_embed_one_attributes_method(assn_name)
          define_method "#{assn_name}_attributes=", -> (values) {
            # data_will_change!
            values ||= {}
            values.symbolize_keys! if values.respond_to?(:symbolize_keys!)
            if values[:_destroy] && (values[:_destroy] == '1')
              self.public_send "#{assn_name}=", nil
            else
              public_send "#{assn_name}=", values
            end              
          }
        end

        def create_embeds_one_validation(assn_name)
          validate_method = "validate_embedded_record_for_#{assn_name}"
          define_method validate_method, -> { validate_embeds_one assn_name }
          validate validate_method
        end

      end
    
    end
  end
end
