require_relative './../test_helper'

class DecimalAttributeTest < MiniTest::Test
  
  def test_attribute_on_model_init
    b = Building.new cost: 5.42
    assert_equal 5.42, b.cost
  end

  def test_attribute_on_existing_model
    b = Building.new
    b.cost = 5.42
    assert_equal 5.42, b.cost
    assert b.cost_changed?
  end
  
  def test_question_mark_method
    b = Building.new cost: 5.42
    assert_equal true, b.cost?
  end
  
  def test_type_conversion_on_init
    b = Building.new cost: '5.42'
    assert_equal 5.42, b.cost
  end
  
  def test_type_conversion_on_existing
    b = Building.new 
    b.cost = '5.42'
    assert_equal 5.42, b.cost
  end

  def test_persistence
    b = Building.new name: 'Test', cost: 87.4
    assert b.save
    assert_equal 87.4, Building.find(b.id).cost.to_f
  end
end
