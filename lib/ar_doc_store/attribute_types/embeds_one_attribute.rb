module ArDocStore
  module AttributeTypes

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
        def #{attribute}
          @#{attribute} || begin
            item = read_store_attribute json_column, :#{attribute}
            item = #{class_name}.build(item) unless item.is_a?(#{class_name})
            @#{attribute} = item
          end
        end

        def #{attribute}=(value)
          if value == '' || !value
            value = nil
          elsif value.is_a?(#{class_name})
            value = value.attributes
          end
          value = #{class_name}.build value
          @#{attribute} = value
          write_store_attribute json_column, :#{attribute}, value
        end
        CODE
      end

      def create_embeds_one_accessors
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def build_#{attribute}(attributes=nil)
          self.#{attribute} = #{class_name}.build(attributes)
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
