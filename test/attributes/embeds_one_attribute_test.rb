require_relative './../test_helper'

class EmbedsOneAttributeTest < MiniTest::Test

  def test_initialized_on_model_init
    entrance = Entrance.new name: 'Foo'
    b = Building.new entrance: entrance
    assert_equal entrance.name, b.entrance.name
  end

  def test_hash_on_model_init
    entrance = { name: 'Foo' }
    b = Building.new entrance: entrance
    assert_equal entrance[:name], b.entrance.name
    assert_equal b, b.entrance.parent
  end

  def test_persistence
    entrance = { name: 'Foo' }
    b = Building.new entrance: entrance
    b.save
    assert_equal entrance[:name], Building.find(b.id).entrance.name
    assert_equal b, b.entrance.parent
  end

  def test_build_method
    b = Building.new
    b.build_entrance name: 'Test'
    assert_equal 'Test', b.entrance.name
  end

  def test_ensure_method
    b = Building.new
    b.ensure_entrance
    assert !!b.entrance
  end

  def test_autosave
    a = Building.new name: 'Foo'
    a.build_entrance
    a.entrance.name = 'Bar'
    a.save
    b = Building.find(a.id)
    assert_equal a.entrance.name, b.entrance.name
    b.entrance.name = 'Baz'
    assert b.entrance_changed?
    assert b.entrance.name_changed?
    assert_equal b.data['entrance']['name'], b.entrance.name
    b.save
    c = Building.find(a.id)
    assert_equal b.data, c.data
    assert_equal 'Baz', c.entrance.name
  end

  def test_attributes_method
    a = Building.new name: 'Foo', entrance_attributes: { name: 'Bar' }
    assert_equal 'Bar', a.entrance.name
  end

  def test_class_name_option
    a = Building.new main_entrance: { name: 'Foo' }
    assert a.main_entrance.is_a?(Entrance)
    assert_equal 'Foo', a.main_entrance.name
  end

  def test_dirty_on_init
    b = Building.new name: 'Foo', entrance: { name: 'Foo' }
    assert b.entrance.name_changed?
  end

  def test_dirty_persisted
    a = Building.create name: 'Foo', entrance: { name: 'Foo' }
    b = Building.find a.id
    assert b.entrance.id.present?
    assert !b.entrance.name_changed?
    b.entrance.name = 'Bar'
    assert b.entrance.name_changed?
    assert_equal 'Foo', b.entrance.name_was
  end
end
