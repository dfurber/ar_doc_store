gem 'activerecord'
gem 'minitest'

require 'minitest/autorun'
require 'active_record'

require_relative './../lib/ar_doc_store'
ActiveRecord::Base.establish_connection(adapter: 'postgresql', database: 'ar_doc_store_test', username: 'postgres', password: 'postgres')

# A building has many entrances and restrooms and some fields of its own
# An entrance has a door, a route, and some fields of its own
# A restroom has a door, a route, and some fields measuring the stalls
# Route and door

# This here is just to mock out enough AR behavior for a model to pretend to be an AR model without a database...
class ARDuck
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::Dirty
  include ActiveModel::Serialization

  attr_accessor :attributes

  def initialize(attrs=nil)
    @attributes = HashWithIndifferentAccess.new
    unless attrs.nil?
      attrs.each { |key, value|
        @jattributes[key] = public_send("#{key}=", value)
      }
    end
    @_initialized = true
  end

  def persisted?
    false
  end

  def inspect
    "#{self.class}: #{attributes.inspect}"
  end

  delegate :as_json, to: :attributes

  def self.store_accessor(store, key)
    key = key.to_sym
    define_method key, -> { read_store_attribute(json_column, key) }
    define_method "#{key}=".to_sym, -> (value) { write_store_attribute json_column, key, value }
  end

  def read_store_attribute(store, key)
    @attributes[key]
  end

  def write_store_attribute(store, key, value)
    #changed_json_attributes[key] = read_store_json_attribute(:data, key) if @_initialized
    @attributes[key] = value
  end

end

class EmptyModel
  include ArDocStore::EmbeddableModel
end

class ThingWithEmptyModel < ARDuck
  include ArDocStore::Model
  embeds_one :empty_model
end

class EmbeddableA < ARDuck
  include ArDocStore::EmbeddableModel
  json_attribute :name
end

class EmbeddableB < EmbeddableA
  json_attribute :gender
end

class Dimensions
  include ArDocStore::EmbeddableModel
  json_attribute :length, :float
  json_attribute :width,  :float
end

class Route
  include ArDocStore::EmbeddableModel
  json_attribute :is_route_unobstructed, as: :boolean
  json_attribute :is_route_lighted, as: :boolean
  json_attribute :route_surface, as: :string
  json_attribute :route_slope_percent, as: :integer
  json_attribute :route_min_width, as: :integer
end

class Door
  include ArDocStore::EmbeddableModel
  enumerates :door_type, multiple: true, values: %w{single double french sliding push pull}
  json_attribute :open_handle,  as: :enumeration, multiple: true, values: %w{push pull plate knob handle}
  json_attribute :close_handle, as: :enumeration, multiple: true, values: %w{push pull plate knob handle}
  json_attribute :clear_distance, as: :integer
  json_attribute :opening_force, as: :integer
  json_attribute :clear_space, as: :integer
end

class Entrance
  include ArDocStore::EmbeddableModel
  embeds_one :route
  embeds_one :door
end

class Restroom
  include ArDocStore::EmbeddableModel
  embeds_one :route
  embeds_one :door

  enumerates :restroom_type, values: %w{single double dirty nasty clean}

  json_attribute :is_restroom_provided, as: :boolean
  json_attribute :is_signage_clear, as: :boolean

  embeds_one :stall_area_dimensions, class_name: 'Dimensions'
  embeds_one :sink_area_dimensions, class_name: 'Dimensions'

  validates :restroom_type, presence: true

end

class Building < ActiveRecord::Base
  include ArDocStore::Model
  json_attribute :name, :string
  json_attribute :comments, as: :string
  json_attribute :finished, :boolean
  json_attribute :stories, as: :integer
  json_attribute :height, as: :float
  json_attribute :architects, as: :array
  json_attribute :construction, as: :enumeration, values: %w{concrete wood brick plaster steel}
  json_attribute :multiconstruction, as: :enumeration, values: %w{concrete wood brick plaster steel}, multiple: true
  json_attribute :strict_enumeration, as: :enumeration, values: %w{happy sad glad bad}, strict: true
  json_attribute :strict_multi_enumeration, as: :enumeration, values: %w{happy sad glad bad}, multiple: true, strict: true
  embeds_many :entrances
  embeds_many :restrooms
end

class PurchaseOrder < ActiveRecord::Base
  include ArDocStore::Model
  attribute :name, :string
  attribute :price, :float
  attribute :approved_at, :datetime
end
