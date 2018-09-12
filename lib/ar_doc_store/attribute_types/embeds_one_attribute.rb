module ArDocStore
  module AttributeTypes

    class EmbedOneType < ActiveModel::Type::Value
      attr_accessor :class_name

      def initialize(class_name)
        @class_name = class_name
      end

      def cast(value)
        if value.nil?
          value
        elsif value.kind_of?(class_name)
          value
        elsif value.respond_to?(:to_hash)
          class_name.new value
        else
          nil
        end
      end

      def serialize(value)
        if value.nil?
          nil
        elsif value.kind_of?(class_name)
          value.serializable_hash
        else
          cast(value).serializable_hash
        end
      end

      def deserialize(value)
        cast(value)
      end

      def changed_in_place?(raw_old_value, new_value)
        serialize(new_value) != raw_old_value
      end
    end

    class EmbedsOneAttribute < BaseAttribute
      attr_reader :class_name
      def build
        @class_name = options[:class_name] || attribute.to_s.classify
        create_accessors
        create_embed_one_attributes_method
        create_embeds_one_accessors
        create_embeds_one_validation
      end

      def create_accessors
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        attribute :#{attribute}, ArDocStore::AttributeTypes::EmbedOneType.new(#{@class_name})
        def #{attribute}
          value = send :attribute, :#{attribute}
          value && value.parent = self 
          value && value.embedded_as = :#{attribute}
          value
        end
        def #{attribute}=(value)
          value = nil if value == '' || value == ['']
          write_attribute :#{attribute}, value
          #{attribute}.parent = self
          #{attribute}.embedded_as = :#{attribute}
          write_store_attribute json_column, :#{attribute}, #{attribute}
          #{attribute}          
        end
        CODE
      end

      def create_embeds_one_accessors
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def build_#{attribute}(attributes=nil)
          self.#{attribute} = #{class_name}.build(attributes, self)
        end
        def ensure_#{attribute}
          #{attribute} || build_#{attribute}
        end
        CODE
      end

      def create_embed_one_attributes_method
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{attribute}_attributes=(values={})
          values.symbolize_keys! if values.respond_to?(:symbolize_keys!)
          if values[:_destroy] && (values[:_destroy] == '1')
            self.#{attribute} = nil
          else
            item = ensure_#{attribute}
            item.attributes = values
            item
          end
        end
        CODE
      end

      def create_embeds_one_validation
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def validate_embedded_record_for_#{attribute}
            validate_embeds_one :#{attribute}
          end
          validate :validate_embedded_record_for_#{attribute}
        CODE
      end

    end

  end
end
