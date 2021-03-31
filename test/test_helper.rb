gem 'activerecord'
gem 'minitest'
gem 'ransack'

require 'minitest/autorun'
require 'active_record'
require 'ransack'

require_relative './../lib/ar_doc_store'
ActiveRecord::Base.establish_connection(adapter: 'postgresql', database: 'ar_doc_store_test', username: 'postgres', password: 'postgres')

require 'active_record/migration'

ActiveRecord::Migration[4.2].execute "DROP TABLE IF EXISTS purchase_orders"
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

# module Arel
#   module Nodes
#     class Contains < Arel::Nodes::InfixOperation
#       def initialize(left, right)
#         super(:'@>', left, right)
#       end
#     end
#   end
#
#   module Visitors
#     class PostgreSQL < Arel::Visitors::ToSql
#       alias_method :visit_Arel_Nodes_Contains, :visit_Arel_Nodes_InfixOperation
#     end
#   end
# end

#
# module ActiveRecord
#   module QueryMethods
#     def contains(predicates)
#       predicates.map do |column, predicate|
#         column = table[column]
#         predicate = column.type_cast_for_database(predicate)
#         predicate = Arel::Nodes.build_quoted(predicate)
#
#         where Arel::Nodes::Contains.new(column, predicate)
#       end
#     end
#   end
#
#   module Querying
#     delegate :contains, to: :all
#   end
# end

# Ransack.configure do |config|
#   # config.add_predicate 'jin', arel_predicate: 'contains', formatter: proc { |v| Arel.sql(v.to_json).gsub(/^"|"$/, "'") }
#   config.add_predicate 'jin', arel_predicate: 'contains', formatter: proc { |v|
#     value = Arel.sql(v.to_json).gsub(/^"|"$/, "'")
#     puts value
#     value
#   }
# end

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
  json_attribute :door_type, as: :enumeration, multiple: true, values: %w{single double french sliding push pull}
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
  json_attribute :html
  embeds_one :entrance
  embeds_one :main_entrance, class_name: 'Entrance'
  embeds_many :restrooms

  validates :stories, numericality: { allow_nil: true }

  scope :multiconstruction_jin, -> (*values) {
    where("data->'multiconstruction' @> ?", values.to_json)
  }
  def self.ransackable_scopes(_auth_object = nil)
    %i[multiconstruction_jin]
  end

end

