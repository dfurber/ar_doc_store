require_relative './../test_helper'

class DirtylAttributeTest < MiniTest::Test

  def test_dirty_attributes_on_model
    b = Building.new name: 'Foo!'
    # This used to work but started failing. AR behavior is to make it true.
    # send :clear_changes_information not working yields undefined method.
    # assert !b.name_changed?
    b.name = 'Bar.'
    assert_equal 'Bar.', b.name
    assert b.name_changed?
    assert_equal 'Foo!', b.name_was
    assert_equal 'Bar.', b.name
  end

  def test_dirty_attributes_on_embedded_model
    b = Building.new
    r = b.build_restroom is_signage_clear: true
    assert !r.is_signage_clear_changed?
    r.is_signage_clear = false
    assert r.is_signage_clear_changed?
    assert_equal true, r.is_signage_clear_was
    assert_equal false, r.is_signage_clear
  end

end