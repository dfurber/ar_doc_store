require_relative './test_helper'

class DirtylAttributeTest < MiniTest::Test

  def test_dirty_attributes_on_model
    b = Building.new name: 'Foo!'
    assert_equal b.name_changed?, false
    b.name = 'Bar.'
    assert b.name_changed?
    assert_equal 'Foo!', b.name_was
    assert_equal 'Bar.', b.name
  end

  def test_dirty_attributes_on_embedded_model
    b = Building.new
    r = b.build_restroom is_signage_clear: true
    assert_equal r.is_signage_clear_changed?, false
    r.is_signage_clear = false
    assert r.is_signage_clear_changed?
    assert_equal true, r.is_signage_clear_was
    assert_equal false, r.is_signage_clear
  end

end