module ArDocStore
  class EmbeddedCollection < Array
    attr_accessor :parent, :embedded_as
    def save
      parent.send :write_store_attribute, parent.json_column, embedded_as, as_json
    end
    def persist
      each &:persist
    end
    def inspect
      "ArDocStore::EmbeddedCollection - #{as_json.inspect}"
    end
  end

  module AttributeTypes
    class EmbedManyType < ActiveModel::Type::Value
      attr_accessor :class_name

      def initialize(class_name)
        @class_name = class_name
      end

      def cast(values)
        @class_name = @class_name.constantize if class_name.respond_to?(:constantize)
        collection = EmbeddedCollection.new
        values && values.each do |value|
          collection << if value.nil?
                          value
                        elsif value.kind_of?(class_name)
                          value
                        elsif value.respond_to?(:to_hash)
                          class_name.new value
                        else
                          nil
                        end
        end
        collection
      end

      def serialize(values)
        if values.nil?
          nil
        elsif values.respond_to?(:each)
          values.map { |value|
            if value.nil?
              nil
            elsif value.kind_of?(class_name)
              value.serializable_hash
            else
              cast(value).serializable_hash
            end
          }.compact
        end
      end

      def deserialize(value)
        cast(value)
      end

      def changed_in_place?(raw_old_value, new_value)
        serialize(new_value) != raw_old_value
      end
    end

    class EmbedsManyAttribute < BaseAttribute
      def store_attribute
        @attribute = attribute.to_sym
        @class_name = options[:class_name] || attribute.to_s.classify
        create_accessors
        create_build_method
        create_ensure_method
        create_embeds_many_attributes
        create_embeds_many_validation
      end

      def embedded?
        true
      end

      private

      def add_method(method, block)
        model.class_eval do
          define_method method, block
        end
      end

      def create_accessors
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        attribute :#{attribute}, ArDocStore::AttributeTypes::EmbedManyType.new("#{@class_name}")
        def #{attribute}
          value = send :attribute, :#{attribute}
          if value && !value.is_a?(ArDocStore::EmbeddedCollection)
            value = ArDocStore::EmbeddedCollection.new value
          else
            value ||= ArDocStore::EmbeddedCollection.new
          end
          value.parent = self
          value.embedded_as = :#{attribute}
          value.each do |item|
            item.parent = value
          end
          value
        end
        def #{attribute}=(value)
          value = nil if value == '' || value == ['']
          send :attribute=, :#{attribute}, value
          new_value = send :attribute, :#{attribute}
          new_value.parent = self
          new_value.embedded_as = :#{attribute}
          new_value.each do |item|
            item.parent = new_value
          end
          write_store_attribute json_column, :#{attribute}, new_value
          new_value          
        end
        CODE
      end

      def create_build_method
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def build_#{attribute.to_s.singularize}(attributes = {})
          items = #{attribute} || ArDocStore::EmbeddedCollection.new
          items.embedded_as = :#{attribute}
          items.parent = self
          item = #{@class_name}.new attributes
          item.parent = #{attribute}
          items << item
          self.#{attribute} = items
          item
        end
        CODE
      end

      def create_ensure_method
        attr_singular = attribute.to_s.singularize
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def ensure_#{attribute}(attributes = nil)
          #{attribute}.first || build_#{attr_singular}(attributes)
        end
        def ensure_#{attr_singular}(attributes = nil)
          #{attribute}.first || build_#{attr_singular}(attributes)
        end
        CODE
      end

      def create_embeds_many_attributes
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{attribute}_attributes=(values)
          return if values.blank?
          if values.respond_to?(:each)
            if values.respond_to?(:values)
              values = values.values
            end
          else
            values = [values]
          end
          self.#{attribute} = AssignEmbedsManyAttributes.new(self, #{@class_name}, :#{attribute}, #{attribute}, values).models
        end
        CODE
      end

      def create_embeds_many_validation
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def validate_embedded_record_for_#{attribute}
            validate_embeds_many :#{attribute}
          end
          validate :validate_embedded_record_for_#{attribute}
        CODE
      end


    end

    class AssignEmbedsManyAttributes
      attr_reader :models, :assn_name, :parent, :class_name
      def initialize(parent, class_name, assn_name, models, values)
        @parent, @class_name, @assn_name, @models, @values = parent, class_name, assn_name, models, values
        @models ||= ArDocStore::EmbeddedCollection.new
        # @models.parent = parent
        # @models.embedded_as = assn_name
        values.each { |value|
          value = value.symbolize_keys
          if value.key?(:id)
            process_existing_model(value)
          else
            next if values.all?(&:nil?)
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
        models << class_name.new(value)
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
