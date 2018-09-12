module ArDocStore
  module Storage

    def self.included(mod)

      mod.class_attribute :json_column
      mod.json_column ||= :data
      mod.class_attribute :json_attributes
      mod.json_attributes ||= HashWithIndifferentAccess.new
      mod.send :extend, ClassMethods
    end

    module ClassMethods
      def json_attribute(name, *args)
        type = args.shift if args.first.is_a?(Symbol)
        options = args.extract_options!
        type ||= options.delete(:as) || :string
        class_name = ArDocStore.mappings[type] || "ArDocStore::Attributes::#{type.to_s.classify}"
        raise "Invalid attribute type: #{class_name}" unless const_defined?(class_name)
        json_attributes[name] = class_name.constantize.build self, name, options
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
    end

  end
end
