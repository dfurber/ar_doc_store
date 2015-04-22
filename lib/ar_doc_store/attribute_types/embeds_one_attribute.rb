module ArDocStore
  module AttributeTypes

    class EmbedsOneAttribute < BaseAttribute
      def build
        assn_name = attribute.to_sym
        class_name = options[:class_name] || attribute.to_s.classify
        create_accessors assn_name, class_name
        create_embed_one_attributes_method(assn_name)
        create_embeds_one_accessors assn_name, class_name
        create_embeds_one_validation(assn_name)
      end

      def create_accessors(assn_name, class_name)
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{assn_name}
          @#{assn_name} || begin
            item = read_store_attribute :data, :#{assn_name}
            item = #{class_name}.build(item) unless item.is_a?(#{class_name})
            @#{assn_name} = item
          end
        end

        def #{assn_name}=(value)
          if value == '' || !value
            value = nil
          elsif !value.is_a?(#{class_name})
            value = #{class_name}.build value
          else

          end
          @#{assn_name} = value
          write_store_attribute :data, :#{assn_name}, value
        end
        CODE
      end

      def create_embeds_one_accessors(assn_name, class_name)
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def build_#{assn_name}(attributes=nil)
          self.#{assn_name} = #{class_name}.build(attributes)
        end
        def ensure_#{assn_name}
          #{assn_name} || build_#{assn_name}
        end
        CODE
      end

      def create_embed_one_attributes_method(assn_name)
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{assn_name}_attributes=(values={})
          values.symbolize_keys! if values.respond_to?(:symbolize_keys!)
          if values[:_destroy] && (values[:_destroy] == '1')
            self.#{assn_name} = nil
          else
            self.#{assn_name} = values
          end
        end
        CODE
      end

      def create_embeds_one_validation(assn_name)
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def validate_embedded_record_for_#{assn_name}
            validate_embeds_one :#{assn_name}
          end
          validate :validate_embedded_record_for_#{assn_name}
        CODE
      end
      
    end

  end
end
