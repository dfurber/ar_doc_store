require "ar_doc_store/version"
require "ar_doc_store/storage"
require "ar_doc_store/embedding"
require "ar_doc_store/model"
require "ar_doc_store/embeddable_model"

module ArDocStore

  module AttributeTypes
    autoload :BaseAttribute, "ar_doc_store/attribute_types/base_attribute"
    autoload :ArrayAttribute, "ar_doc_store/attribute_types/array_attribute"
    autoload :BooleanAttribute, "ar_doc_store/attribute_types/boolean_attribute"
    autoload :EnumerationAttribute, "ar_doc_store/attribute_types/enumeration_attribute"
    autoload :FloatAttribute, "ar_doc_store/attribute_types/float_attribute"
    autoload :IntegerAttribute, "ar_doc_store/attribute_types/integer_attribute"
    autoload :StringAttribute, "ar_doc_store/attribute_types/string_attribute"
    autoload :UuidAttribute, "ar_doc_store/attribute_types/uuid_attribute"
    autoload :EmbedsOneAttribute, "ar_doc_store/attribute_types/embeds_one_attribute"
    autoload :EmbedsManyAttribute, "ar_doc_store/attribute_types/embeds_many_attribute"
  end

  @mappings = Hash.new
  @mappings[:array]       = 'ArDocStore::AttributeTypes::ArrayAttribute'
  @mappings[:boolean]     = 'ArDocStore::AttributeTypes::BooleanAttribute'
  @mappings[:enumeration] = 'ArDocStore::AttributeTypes::EnumerationAttribute'
  @mappings[:float]       = 'ArDocStore::AttributeTypes::FloatAttribute'
  @mappings[:integer]     = 'ArDocStore::AttributeTypes::IntegerAttribute'
  @mappings[:string]      = 'ArDocStore::AttributeTypes::StringAttribute'
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

  def self.clobber_attribute_method!
    ArDocStore::Storage::ClassMethods.module_eval do
      def attribute(*args)
        json_attribute *args
      end
    end
  end
end
