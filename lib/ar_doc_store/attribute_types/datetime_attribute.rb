module ArDocStore
  module AttributeTypes
    class DatetimeAttribute < BaseAttribute
      def build
        attribute = @attribute
        load_method = load
        dump_method = dump
        default_value = default
        json_column = :data
        model.class_eval do
          add_ransacker(attribute, 'timestamp')
          define_method attribute.to_sym, -> {
            value = read_store_attribute(json_column, attribute)
            if value
              value.public_send(dump_method)
            elsif default_value
              write_default_store_attribute(attribute, default_value)
              default_value
            end
          }
          define_method "#{attribute}=".to_sym, -> (value) {
            if value.blank?
              write_store_attribute(json_column, attribute, nil)
            else
              write_store_attribute(json_column, attribute, value.public_send(load_method))
            end
          }
        end
      end

      def type
        :datetime
      end

      def dump
        :to_time
      end

      def load
        :to_s
      end
    end
  end
end