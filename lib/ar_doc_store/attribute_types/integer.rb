module ArDocStore
  module AttributeTypes

    class IntegerAttribute < Base
      def conversion
        :to_i
      end

      def predicate
        'int'
      end

      def column_type
        ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Integer.new
      end

    end

  end
end
