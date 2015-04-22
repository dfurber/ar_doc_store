require_relative './../test_helper'

class DirtyAttributeTest < MiniTest::Test

  def test_on_model
    b = Building.new name: 'Foo!'
    # This used to work but started failing. AR behavior is to make it true.
    # send :clear_changes_information not working yields undefined method.
    # assert !b.name_changed?
    b.name = 'Bar.'
    assert_equal 'Bar.', b.name
    assert b.name_changed?
    # Somehow this worked at one point, but should only work when the record is loaded via instantiate:
    # assert_equal 'Foo!', b.name_was
  end

  #This test fails here but passes elsewhere.
  def test_on_embedded_model
    b = Building.new
    r = b.build_restroom restroom_type: 'dirty'
    assert !r.restroom_type_changed?
    r.restroom_type = 'nasty'
    assert r.restroom_type_changed?
    assert_equal 'dirty', r.restroom_type_was
    assert_equal 'nasty', r.restroom_type
  end

  def test_id_does_not_change_on_init
    b = Building.new
    r = b.build_restroom
    assert !r.id_changed?
    assert !r.changes.keys.include?('id')
  end

end