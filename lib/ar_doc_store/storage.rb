module ArDocStore
  module Storage

    def self.included(mod)

      mod.class_attribute :json_column
      mod.json_column ||= :data
      mod.class_attribute :json_attributes
      mod.json_attributes ||= HashWithIndifferentAccess.new

      mod.send :include, InstanceMethods
      mod.send :extend, ClassMethods
    end

    module InstanceMethods

      def json_column
        self.class.json_column
      end

      # def write_attribute(name, value)
      #   if is_stored_attribute?(name)
      #     write_store_attribute json_column, attribute_name_from_foreign_key(name), value
      #   else
      #     super
      #   end
      # end
      #
      # def read_attribute(name)
      #   if is_stored_attribute?(name)
      #     read_store_attribute json_column, attribute_name_from_foreign_key(name)
      #   else
      #     super
      #   end
      # end
      #
      # private
      #
      # def is_stored_attribute?(name)
      #   name = name.to_sym
      #   is_store_accessor_method?(name) || name =~ /data\-\>\>/
      # end
      #
      # def is_store_accessor_method?(name)
      #   name = name.to_sym
      #   self.class.stored_attributes[json_column] && self.class.stored_attributes[json_column].include?(name)
      # end
      #
      # def attribute_name_from_foreign_key(name)
      #   is_store_accessor_method?(name) ? name : name.match(/\'(\w+)\'/)[0].gsub("'", '')
      # end
      #
      # def clean_attribute_names_for_arel(attribute_names)
      #   attribute_names.reject{|attribute_name| is_stored_attribute?(attribute_name)}
      # end
      #
      # # Overridden otherwise insert and update queries get fooled into thinking that stored attributes are real columns.
      # def arel_attributes_with_values_for_create(attribute_names) #:nodoc:
      #   super clean_attribute_names_for_arel(attribute_names)
      # end
      #
      # # Overridden otherwise insert and update queries get fooled into thinking that stored attributes are real columns.
      # def arel_attributes_with_values_for_update(attribute_names) #:nodoc:
      #   super clean_attribute_names_for_arel(attribute_names)
      # end
    end

    module ClassMethods

      def json_attribute(name, *args)
        type = args.shift if args.first.is_a?(Symbol)
        options = args.extract_options!
        type ||= options.delete(:as) || :string
        class_name = ArDocStore.mappings[type] || "ArDocStore::AttributeTypes::#{type.to_s.classify}Attribute"
        raise "Invalid attribute type: #{class_name}" unless const_defined?(class_name)
        class_name.constantize.build self, name, options
      end

      #:nodoc:
      def add_ransacker(key, predicate = nil)
        return unless respond_to?(:ransacker)
        ransacker key do |parent|
          sql = "(#{parent.table[:data]}->>'#{key}')"
          if predicate
            sql = "#{sql}::#{predicate}"
          end
          Arel.sql(sql)
        end
      end


      # TODO: Remove the following deprecated methods once projects that use them have been refactored.
      #:nodoc:
      def store_attributes(typecast_method, predicate=nil, attributes=[], default_value=nil)
        attributes = [attributes] unless attributes.respond_to?(:each)
        attributes.each do |key|
          store_attribute key, typecast_method, predicate, default_value
        end
      end

      # Allows you to define several string attributes at once. Deprecated.
      def string_attributes(*args)
        args.each do |arg|
          json_attribute arg, as: :string
        end
      end

      # Allows you to define several float attributes at once. Deprecated.
      def float_attributes(*args)
        args.each do |arg|
          json_attribute arg, as: :float
        end
      end

      # Allows you to define several integer attributes at once. Deprecated.
      def integer_attributes(*args)
        args.each do |arg|
          json_attribute arg, as: :integer
        end
      end

      # Allows you to define several boolean attributes at once. Deprecated.
      def boolean_attributes(*args)
        args.each do |arg|
          json_attribute arg, as: :boolean
        end
      end

      # Shorthand for attribute :name, as: :enumeration, values: %w{a b c}
      # Deprecated.
      def enumerates(field, *args)
        options = args.extract_options!
        options[:as] = :enumeration
        json_attribute field, options
      end


    end

  end
end
