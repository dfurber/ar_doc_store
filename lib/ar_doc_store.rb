require "ar_doc_store/version"
require "ar_doc_store/storage"
require "ar_doc_store/embedding"
require "ar_doc_store/model"
require "ar_doc_store/embeddable_model"
require "ar_doc_store/embedded_collection"

module ArDocStore

  module Attributes
    autoload :Base, "ar_doc_store/attributes/base"
    autoload :Array, "ar_doc_store/attributes/array"
    autoload :Boolean, "ar_doc_store/attributes/boolean"
    autoload :Enumeration, "ar_doc_store/attributes/enumeration"
    autoload :Float, "ar_doc_store/attributes/float"
    autoload :Integer, "ar_doc_store/attributes/integer"
    autoload :String, "ar_doc_store/attributes/string"
    autoload :EmbedsOne, "ar_doc_store/attributes/embeds_one"
    autoload :EmbedsMany, "ar_doc_store/attributes/embeds_many"
    autoload :Datetime, "ar_doc_store/attributes/datetime"
    autoload :Date, "ar_doc_store/attributes/date"
    autoload :Decimal, "ar_doc_store/attributes/decimal"
    autoload :CallbackSupport, "ar_doc_store/attributes/callback_support"
    autoload :EmbedsBase, "ar_doc_store/attributes/embeds_base"
  end

  module Types
    autoload :EmbedsOne, "ar_doc_store/types/embeds_one"
    autoload :EmbedsMany, "ar_doc_store/types/embeds_many"
  end

  @mappings = Hash.new
  @mappings[:array]       = 'ArDocStore::Attributes::Array'
  @mappings[:boolean]     = 'ArDocStore::Attributes::Boolean'
  @mappings[:enumeration] = 'ArDocStore::Attributes::Enumeration'
  @mappings[:float]       = 'ArDocStore::Attributes::Float'
  @mappings[:integer]     = 'ArDocStore::Attributes::Integer'
  @mappings[:string]      = 'ArDocStore::Attributes::String'
  @mappings[:datetime]    = 'ArDocStore::Attributes::Datetime'
  @mappings[:date]        = 'ArDocStore::Attributes::Date'
  @mappings[:decimal]     = 'ArDocStore::Attributes::Decimal'

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
