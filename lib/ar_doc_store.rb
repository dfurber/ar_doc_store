require "ar_doc_store/version"
require "ar_doc_store/storage"
require "ar_doc_store/embedding/embeds_one"
require "ar_doc_store/embedding/embeds_many"
require "ar_doc_store/embedding/core"
require "ar_doc_store/embedding"
require "ar_doc_store/model"
require "ar_doc_store/embeddable_model"
require "ar_doc_store/attribute_types/base"
require "ar_doc_store/attribute_types/array"
require "ar_doc_store/attribute_types/boolean"
require "ar_doc_store/attribute_types/enumeration"
require "ar_doc_store/attribute_types/float"
require "ar_doc_store/attribute_types/integer"
require "ar_doc_store/attribute_types/string"

module ArDocStore
  @mappings = Hash.new
  @mappings[:array]       = 'ArDocStore::AttributeTypes::ArrayAttribute'
  @mappings[:boolean]     = 'ArDocStore::AttributeTypes::BooleanAttribute'
  @mappings[:enumeration] = 'ArDocStore::AttributeTypes::EnumerationAttribute'
  @mappings[:float]       = 'ArDocStore::AttributeTypes::FloatAttribute'
  @mappings[:integer]     = 'ArDocStore::AttributeTypes::IntegerAttribute'
  @mappings[:string]      = 'ArDocStore::AttributeTypes::StringAttribute'
  
  def self.mappings
    @mappings
  end
end
