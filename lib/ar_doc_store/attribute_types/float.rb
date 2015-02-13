module ArDocStore
  module AttributeTypes

    class FloatAttribute < Base
      def conversion
        :to_f
      end

      def predicate
        'float'
      end

      def column_type
        ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Decimal.new
      end

    end

  end
end
