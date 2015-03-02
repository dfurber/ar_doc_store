gem 'activerecord'
gem 'minitest'

require 'minitest/autorun'
require 'active_record'

require_relative './../lib/ar_doc_store'

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
    return if attrs.nil?
    attrs.each { |key, value|
      key = "#{key}=".to_sym
      self.public_send(key, value) if methods.include?(key)
    }
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
    define_method key, -> { read_store_attribute(:data, key) }
    define_method "#{key}=".to_sym, -> (value) { write_store_attribute :data, key, value }
  end

  def read_store_attribute(store, key)
    @attributes[key]
  end

  def write_store_attribute(store, key, value)
    changed_attributes[key] = read_store_attribute(:data, key)
    @attributes[key] = value
  end

  def data_will_change!
    true
  end
  
  def self.columns_hash
    @@columns_hash ||= HashWithIndifferentAccess.new
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
  attribute :name
end

class EmbeddableB < EmbeddableA
  attribute :gender
end

class Dimensions
  include ArDocStore::EmbeddableModel
  attribute :length, :float
  attribute :width,  :float
end

class Route
  include ArDocStore::EmbeddableModel
  attribute :is_route_unobstructed, as: :boolean
  attribute :is_route_lighted, as: :boolean
  attribute :route_surface, as: :string
  attribute :route_slope_percent, as: :integer
  attribute :route_min_width, as: :integer
end

class Door
  include ArDocStore::EmbeddableModel
  attribute :id, :uuid
  enumerates :door_type, multiple: true, values: %w{single double french sliding push pull}
  attribute :open_handle,  as: :enumeration, multiple: true, values: %w{push pull plate knob handle}
  attribute :close_handle, as: :enumeration, multiple: true, values: %w{push pull plate knob handle}
  attribute :clear_distance, as: :integer
  attribute :opening_force, as: :integer
  attribute :clear_space, as: :integer
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

  attribute :is_restroom_provided, as: :boolean
  attribute :is_signage_clear, as: :boolean

  embeds_one :stall_area_dimensions, class_name: 'Dimensions'
  embeds_one :sink_area_dimensions, class_name: 'Dimensions'
  
  validates :restroom_type, presence: true
  
end

class Building < ARDuck
  include ArDocStore::Model
  attribute :name, :string
  attribute :comments, as: :string
  attribute :finished, :boolean
  attribute :stories, as: :integer
  attribute :height, as: :float
  attribute :construction, as: :enumeration, values: %w{concrete wood brick plaster steel}
  attribute :multiconstruction, as: :enumeration, values: %w{concrete wood brick plaster steel}, multiple: true
  attribute :strict_enumeration, as: :enumeration, values: %w{happy sad glad bad}, strict: true
  attribute :strict_multi_enumeration, as: :enumeration, values: %w{happy sad glad bad}, multiple: true, strict: true
  embeds_many :entrances
  embeds_many :restrooms
end

