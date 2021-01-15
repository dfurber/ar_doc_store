# frozen_string_literal: true

module ArDocStore
  class EmbeddedCollection < Array
    attr_accessor :parent, :embedded_as
    def save
      parent.send :write_store_attribute, parent.json_column, embedded_as, as_json
    end

    def persist
      each &:persist
    end

    def inspect
      "ArDocStore::EmbeddedCollection - #{as_json.inspect}"
    end
  end
end
