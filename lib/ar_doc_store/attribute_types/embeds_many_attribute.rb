module ArDocStore

  class EmbeddedCollection < Array
    attr_accessor :parent
  end

  module AttributeTypes

    class EmbedsManyAttribute < BaseAttribute

      def build
        assn_name = attribute.to_sym
        class_name = options[:class_name] || attribute.to_s.classify
        model.store_accessor model.json_column, assn_name
        create_reader_for assn_name, class_name
        create_writer_for assn_name, class_name
        create_build_method_for assn_name, class_name
        create_ensure_method_for assn_name
        create_embeds_many_attributes_method(class_name, assn_name)
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
          instance_variable_get(ivar) || begin
            my_class_name = class_name.constantize
            items = read_store_attribute(json_column, assn_name)
            if items.is_a?(Array) || items.is_a?(ArDocStore::EmbeddedCollection)
              items = ArDocStore::EmbeddedCollection.new items.map { |item| item.is_a?(my_class_name) ? item : my_class_name.build(item) }
            else
              items ||= ArDocStore::EmbeddedCollection.new
            end
            instance_variable_set ivar, (items)
            items.parent = self
            items.map {|item| item.parent = self }
            items
          end
        }
      end
      def create_writer_for(assn_name, class_name)
        add_method "#{assn_name}=".to_sym, -> (values) {
          if values && values.respond_to?(:map)
            items = ArDocStore::EmbeddedCollection.new values.map { |item|
              my_class_name = class_name.constantize
              item = item.is_a?(my_class_name) ? item : my_class_name.new(item)
              item.id
              item.parent = self
              item
            }
          else
            items = []
          end
          items.parent = self
          instance_variable_set "@#{assn_name}", write_store_attribute(json_column, assn_name, items)
        }
      end

      def create_build_method_for(assn_name, class_name)
        add_method "build_#{assn_name.to_s.singularize}", -> (attributes=nil) {
          assns = self.public_send assn_name
          item = class_name.constantize.build attributes
          item.parent = self
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

      def create_embeds_many_attributes_method(class_name, assn_name)
        add_method "#{assn_name}_attributes=", -> (values) {
          return if values.blank?
          # if it's a single item then wrap it in an array but how to tell?

          if values.respond_to?(:each)
            if values.respond_to?(:values)
              values = values.values
            end
          else
            values = [values]
          end
          models = public_send assn_name
          public_send "#{assn_name}=", AssignEmbedsManyAttributes.new(self, class_name, assn_name, models, values).models
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

    class AssignEmbedsManyAttributes
      attr_reader :models, :assn_name, :parent, :class_name
      def initialize(parent, class_name, assn_name, models, values)
        @parent, @class_name, @assn_name, @models, @values = parent, class_name, assn_name, models, values
        values.each { |value|
          value = value.symbolize_keys
          if value.key?(:id)
            process_existing_model(value)
          else
            add(value)
          end
        }
      end

      private

      attr_writer :models, :values
      attr_reader :values, :assn_name

      def process_existing_model(value)
        return false unless value.key?(:id)
        model = find_model_by_value(value)
        model && destroy_or_update(model, value) or add(value)
      end

      def destroy_or_update(model, value)
        destroy(model, value) or update_attributes(model, value)
      end

      def add(value)
        models << class_name.constantize.new(value)
      end

      def destroy(model, value)
        wants_to_die?(value) && models.delete(model)
      end

      def update_attributes(model, value)
        model.attributes = value
      end

      def wants_to_die?(value)
        value.key?(:_destroy) && ArDocStore.convert_boolean(value[:_destroy])
      end

      def find_model_by_value(value)
        models.detect { |item| item.id == value[:id] }
      end
    end


  end
end
