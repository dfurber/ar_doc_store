require "ar_doc_store/version"
require "ar_doc_store/storage"
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
require "ar_doc_store/attribute_types/uuid"
require "ar_doc_store/attribute_types/json"
require "ar_doc_store/attribute_types/embeds_one"
require "ar_doc_store/attribute_types/embeds_many"
require 'hashie'
module ArDocStore
  @mappings = Hash.new
  @mappings[:array]       = 'ArDocStore::AttributeTypes::ArrayAttribute'
  @mappings[:boolean]     = 'ArDocStore::AttributeTypes::BooleanAttribute'
  @mappings[:enumeration] = 'ArDocStore::AttributeTypes::EnumerationAttribute'
  @mappings[:float]       = 'ArDocStore::AttributeTypes::FloatAttribute'
  @mappings[:integer]     = 'ArDocStore::AttributeTypes::IntegerAttribute'
  @mappings[:string]      = 'ArDocStore::AttributeTypes::StringAttribute'
  @mappings[:json]        = 'ArDocStore::AttributeTypes::JsonAttribute'
  @mappings[:uuid]        = 'ArDocStore::AttributeTypes::UuidAttribute'

  def self.mappings
    @mappings
  end
  
  def self.convert_boolean(bool)
    if bool.is_a?(String)
      return true if bool == true || bool =~ (/^(true|t|yes|y|1)$/i)
      return false if bool == false || bool.blank? || bool =~ (/^(false|f|no|n|0)$/i)
    elsif bool.is_a?(Integer)
      return bool > 0
    elsif bool.is_a?(TrueClass)
      return true
    elsif bool.is_a?(FalseClass)
      return false
    else
      return nil
    end
  end
end

