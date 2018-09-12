require_relative './../test_helper'

class EmbedsManyAttributeTest < MiniTest::Test

  def test_initialized_on_model_init
    r = Restroom.new name: 'Foo'
    b = Building.new restrooms: [r]
    assert_equal r.name, b.restrooms.first.name
  end

  def test_hash_on_model_init
    r = { name: 'Foo' }
    b = Building.new restrooms: [r]
    assert_equal r[:name], b.restrooms.first.name
    assert_equal b, b.restrooms.first.parent.parent
  end

  def test_persistence
    r = { name: 'Foo' }
    b = Building.new restrooms: [r]
    b.save
    assert_equal r[:name], Building.find(b.id).restrooms.first.name
    assert_equal b, b.restrooms.first.parent.parent
  end

  def test_build_method
    b = Building.new
    b.build_restroom name: 'Test'
    assert_equal 'Test', b.restrooms.first.name
  end

  def test_ensure_method
    b = Building.new
    b.ensure_restroom
    assert !!b.restrooms.first
  end

  def test_autosave
    a = Building.new name: 'Foo'
    r = a.build_restroom
    r.name = 'Bar'
    a.save
    b = Building.find(a.id)
    assert_equal r.name, b.restrooms.first.name
    b.restrooms.first.name = 'Baz'
    b.save
    c = Building.find(a.id)
    assert_equal 'Baz', c.restrooms.first.name
  end

  def test_attributes_method
    a = Building.new name: 'Foo', restrooms_attributes: { 0 => { name: 'Bar' } }
    assert_equal 'Bar', a.restrooms.first.name
  end

  def test_dirty_on_init
    b = Building.new name: 'Foo', restrooms: [{ name: 'Foo' }]
    assert b.restrooms.first.name_changed?
  end

  def test_dirty_persisted
    a = Building.create name: 'Foo', restrooms: [{ name: 'Foo' }]
    b = Building.find a.id
    assert !b.restrooms.first.name_changed?
    b.restrooms.first.name = 'Bar'
    assert_equal 'Bar', b.restrooms.first.name
    assert b.restrooms.first.name_changed?
    assert_equal 'Foo', b.restrooms.first.name_was
  end

  def test_rejects_all_blank
    a = Building.new name: 'Foo'
    a.restrooms_attributes = { 0 => { name: nil }}
    a.save
    b = Building.find a.id
    assert_equal 0, b.restrooms.size
  end
end
