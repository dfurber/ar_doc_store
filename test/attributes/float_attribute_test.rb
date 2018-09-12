require_relative './../test_helper'

class FloatAttributeTest < MiniTest::Test
  
  def test_attribute_on_model_init
    b = Building.new height: 5.42
    assert_equal 5.42, b.height
  end

  def test_attribute_on_existing_model
    b = Building.new
    b.height = 5.42
    assert_equal 5.42, b.height
    assert b.height_changed?
  end
  
  def test_question_mark_method
    b = Building.new height: 5.42
    assert_equal true, b.height?
  end
  
  def test_type_conversion_on_init
    b = Building.new height: '5.42'
    assert_equal 5.42, b.height
  end
  
  def test_type_conversion_on_existing
    b = Building.new 
    b.height = '5.42'
    assert_equal 5.42, b.height
  end

  def test_persistence
    b = Building.new name: 'Test', height: 87.4
    assert b.save
    assert_equal 87.4, Building.find(b.id).height
  end
end
