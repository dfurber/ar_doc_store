gem 'activerecord'
gem 'minitest'

require 'minitest/autorun'
require 'active_record'

require_relative './../lib/ar_doc_store'
ActiveRecord::Base.establish_connection(adapter: 'postgresql', database: 'ar_doc_store_test', username: 'postgres', password: 'postgres')

require 'active_record/migration'

ActiveRecord::Migration.execute "DROP TABLE IF EXISTS purchase_orders"
ActiveRecord::Migration.execute "DROP TABLE IF EXISTS buildings"
ActiveRecord::Migration.create_table :buildings do |t|
  t.jsonb :data
end
ActiveRecord::Migration.create_table :purchase_orders do |t|
  t.jsonb :data
  t.belongs_to :building, index: true, foreign_key: true
end

# require 'simplecov'
# SimpleCov.start

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

  validates :clear_space, numericality: { allow_nil: true }
end

class Entrance
  include ArDocStore::EmbeddableModel
  json_attribute :name
end

class Restroom
  include ArDocStore::EmbeddableModel
  json_attribute :name
end

class Building < ActiveRecord::Base
  include ArDocStore::Model
  json_attribute :name, :string
  json_attribute :comments, as: :string
  json_attribute :finished, :boolean
  json_attribute :stories, as: :integer
  json_attribute :number_with_default, as: :integer, default: 12
  json_attribute :height, as: :float
  json_attribute :architects, as: :array
  json_attribute :construction, as: :enumeration, values: %w{concrete wood brick plaster steel}
  json_attribute :multiconstruction, as: :enumeration, values: %w{concrete wood brick plaster steel}, multiple: true
  json_attribute :strict_enumeration, as: :enumeration, values: %w{happy sad glad bad}, strict: true
  json_attribute :strict_multi_enumeration, as: :enumeration, values: %w{happy sad glad bad}, multiple: true, strict: true
  json_attribute :inspected_at, as: :datetime
  json_attribute :finished_on, as: :date
  json_attribute :cost, as: :decimal
  embeds_one :entrance
  embeds_one :main_entrance, class_name: 'Entrance'
  embeds_many :restrooms

  validates :stories, numericality: { allow_nil: true }
end

