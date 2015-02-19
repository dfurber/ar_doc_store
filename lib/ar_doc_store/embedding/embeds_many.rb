module ArDocStore
  module Embedding
      module EmbedsMany

        def self.included(base)
          base.send :extend, ClassMethods
          base.send :include, InstanceMethods
        end
        
        module InstanceMethods
          # Validate the embedded records
          def validate_embeds_many(assn_name)
            if records = public_send(assn_name)
              records.each { |record| embed_valid?(assn_name, record) }
            end
          end

        end
    
        module ClassMethods

          def embeds_many(assn_name, *args)
            store_accessor :data, assn_name
            options = args.extract_options!
            class_name = options[:class_name] || assn_name.to_s.classify
            create_embeds_many_accessors(assn_name, class_name)
            create_embed_many_attributes_method(assn_name)
            create_embeds_many_validation(assn_name)
          end

          private

          def create_embeds_many_accessors(assn_name, class_name)
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

          def create_embed_many_attributes_method(assn_name)
            define_method "#{assn_name}_attributes=", -> (values) {
              data_will_change!
              values = values.andand.values || []
              values = values.reject { |item| item['_destroy'] == '1' }
              public_send "#{assn_name}=", values
            }
          end

          def create_embeds_many_validation(assn_name)
            validate_method = "validate_embedded_record_for_#{assn_name}"
            define_method validate_method, -> { validate_embeds_many assn_name }
            validate validate_method
          end

        end
    
    end
  end
end
