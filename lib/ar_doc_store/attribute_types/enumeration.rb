module ArDocStore
  module AttributeTypes

    class EnumerationAttribute < Base
      
      def build
        key = attribute.to_sym
        dictionary = options[:values]
        multiple = options[:multiple]
        strict = options[:strict]
        model.class_eval do
          
          if multiple
            attribute key, as: :array
            if strict
              define_method "validate_#{key}" do
                value = public_send(key)
                errors.add(key, :invalid) if value.is_a?(Array) && value.present? && value.reject(&:blank?).detect {|d| !dictionary.include?(d)}
              end
              validate "validate_#{key}".to_sym
            end
            # TODO should we do anything for strict option?
          else
            attribute key, as: :string
            if strict
              validates_inclusion_of key, in: dictionary, allow_blank: true
            end
          end
          define_singleton_method "#{key}_choices" do
            dictionary
          end
        end
      end

    end
  end
end
