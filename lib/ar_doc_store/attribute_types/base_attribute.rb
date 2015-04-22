module ArDocStore
  module AttributeTypes
    class BaseAttribute
      attr_accessor :conversion, :predicate, :options, :model, :attribute, :default

      def self.build(model, attribute, options={})
        new(model, attribute, options).build
      end

      def initialize(model, attribute, options)
        @model, @attribute, @options = model, attribute, options
        @model.virtual_attributes[attribute] = self
        @default = options.delete(:default)
      end

      def build
        store_attribute
      end

      #:nodoc:
      def store_attribute
        attribute = @attribute
        typecast_method = conversion
        predicate = @predicate
        default_value = default
        model.class_eval do
          add_ransacker(attribute, predicate)
          define_method attribute.to_sym, -> {
            value = read_store_attribute(:data, attribute)
            if value
              value.public_send(typecast_method)
            elsif default_value
              write_default_store_attribute(attribute, default_value)
              default_value
            end
          }
          define_method "#{attribute}=".to_sym, -> (value) {
            if value == '' || value.nil?
              write_store_attribute :data, attribute, nil
            else
              write_store_attribute(:data, attribute, value.public_send(typecast_method))
            end
          }
        end
      end



    end

  end
end
