require_relative 'test_helper'

class CompatibilityLeaf
  include ArDocStore::EmbeddableModel
  json_attribute :name, :string
  validates :name, presence: true
end

class CompatibilityBranch
  include ArDocStore::EmbeddableModel
  embeds_one :leaf, class_name: 'CompatibilityLeaf'
  embeds_many :items, class_name: 'CompatibilityLeaf'
end

class CompatibilityDocument < ActiveRecord::Base
  self.table_name = 'buildings'
  include ArDocStore::Model
  embeds_one :branch, class_name: 'CompatibilityBranch'
  embeds_many :items, class_name: 'CompatibilityLeaf'
end

class RailsCompatibilityTest < Minitest::Test
  def test_invalid_nested_child_prevents_save_and_preserves_error_details
    document = CompatibilityDocument.new
    document.build_branch.build_leaf

    refute document.save
    assert document.new_record?
    assert_equal ["can't be blank"], document.errors[:'branch.leaf.name']
    assert_equal [{ error: :blank }], document.errors.details[:'branch.leaf.name']
    refute document.valid?
    assert_equal 1, document.errors.size
  end

  def test_invalid_collection_child_prevents_save
    document = CompatibilityDocument.new
    document.build_item

    refute document.save
    assert_equal ["can't be blank"], document.errors[:'items.name']
  end

  def test_nested_one_and_many_survive_save_reload_and_updates
    document = CompatibilityDocument.new
    branch = document.build_branch
    branch.build_leaf(name: 'one')
    branch.items = [{ name: 'many' }]
    document.save!
    document.reload

    assert_equal 'one', document.branch.leaf.name
    assert_equal 'many', document.branch.items.first.name
    assert document.branch.leaf.persisted?
    assert document.branch.items.first.persisted?
    refute document.branch.leaf.name_changed?
    assert_same document.branch, document.branch.leaf.parent
    assert_same document.branch, document.branch.items.parent

    document.branch.leaf.name = 'updated one'
    document.branch.items.first.name = 'updated many'
    document.save!
    document.reload
    assert_equal 'updated one', document.branch.leaf.name
    assert_equal 'updated many', document.branch.items.first.name
  end
end
