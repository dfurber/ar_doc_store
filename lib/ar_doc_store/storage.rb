module ArDocStore
  module Storage
    
    def self.included(mod)
      mod.send :include, InstanceMethods
      mod.send :extend, ClassMethods
    end
    
    module InstanceMethods
      
      def write_attribute(name, value)
        if is_stored_attribute?(name)
          write_store_attribute :data, attribute_name_from_foreign_key(name), value
        else
          super
        end
      end

      def read_attribute(name)
        if is_stored_attribute?(name)
          read_store_attribute :data, attribute_name_from_foreign_key(name)
        else
          super
        end
      end
      
      private
      
      def is_stored_attribute?(name)
        name = name.to_sym
        is_store_accessor_method?(name) || name =~ /data\-\>\>/
      end

      def is_store_accessor_method?(name)
        name = name.to_sym
        self.class.stored_attributes[:data] && self.class.stored_attributes[:data].include?(name)
      end

      def attribute_name_from_foreign_key(name)
        is_store_accessor_method?(name) ? name : name.match(/\'(\w+)\'/)[0].gsub("'", '')
      end
      
    end
    
    module ClassMethods
      
      def attribute(name, *args)
        type = args.shift if args.first.is_a?(Symbol)
        options = args.extract_options!
        type ||= options.delete(:as) || :string
        class_name = ArDocStore.mappings[type]
        unless const_defined?(class_name)
          raise "Invalid attribute type: #{name}"
        end
        class_name = class_name.constantize
        class_name.build self, name, options
      end

      def add_ransacker(key, predicate = nil)
        return unless respond_to?(:ransacker)
        ransacker key do
          sql = "(data->>'#{key}')"
          if predicate
            sql = "#{sql}::#{predicate}"
          end
          Arel.sql(sql)
        end
      end

      def store_attributes(typecast_method, predicate=nil, attributes=[])
        attributes = [attributes] unless attributes.respond_to?(:each)
        attributes.each do |key|
          store_accessor :data, key
          add_ransacker(key, predicate)
          if typecast_method.is_a?(Symbol)
            store_attribute_from_symbol typecast_method, key
          else
            store_attribute_from_class typecast_method, key
          end
        end
      end

      def store_attribute_from_symbol(typecast_method, key)
        define_method key.to_sym, -> { 
          value = read_store_attribute(:data, key)
          value.public_send(typecast_method) if value
        }
        define_method "#{key}=".to_sym, -> (value) {
          # data_will_change! if @initalized
          write_store_attribute(:data, key, value.public_send(typecast_method))
        }
      end

      def store_attribute_from_class(class_name, key)
        define_method key.to_sym, -> {
          ivar = "@#{key}"
          existing = instance_variable_get ivar
          existing || begin
            item = read_store_attribute(:data, key)
            class_name = class_name.constantize if class_name.respond_to?(:constantize)
            item = class_name.new(item) unless item.is_a?(class_name)
            instance_variable_set ivar, item
            item
          end
        }
        define_method "#{key}=".to_sym, -> (value) {
          ivar = "@#{key}"
          class_name = class_name.constantize if class_name.respond_to?(:constantize)
          value = class_name.new(value) unless value.is_a?(class_name)
          instance_variable_set ivar, value
          write_store_attribute :data, key, value
          # data_will_change! if @initialized
        }
      end

      def string_attributes(*args)
        args.each do |arg|
          attribute arg, as: :string
        end
      end

      def float_attributes(*args)
        args.each do |arg|
          attribute arg, as: :float
        end
      end

      def integer_attributes(*args)
        args.each do |arg|
          attribute arg, as: :integer
        end
      end

      def boolean_attributes(*args)
        args.each do |arg|
          attribute arg, as: :boolean
        end
      end
      
      def enumerates(field, *args)
        options = args.extract_options!
        options[:as] = :enumeration
        attribute field, options
      end

    
    end
    
  end
end