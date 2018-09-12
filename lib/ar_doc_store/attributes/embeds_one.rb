module ArDocStore
  module Attributes
    class EmbedsOne < EmbedsBase
      private

      def store_attribute
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        attribute :#{attribute}, ArDocStore::Types::EmbedsOne.new("#{@class_name}")
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

      def create_build_method
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def build_#{attribute}(attributes=nil)
          self.#{attribute} = #{class_name}.build(attributes, self)
        end
        CODE
      end

      def create_ensure_method
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def ensure_#{attribute}
          #{attribute} || build_#{attribute}
        end
        CODE
      end

      def create_attributes_method
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

      def create_validation
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
