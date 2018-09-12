require_relative './../test_helper'

class ArrayAttributeTest < MiniTest::Test
  
  def test_attribute_on_model_init
    architects = %W{Bob John Billy Bob}
    b = Building.new architects: architects
    assert_equal architects, b.architects
  end

  def test_attribute_on_existing_model
    architects = %W{Bob John Billy Bob}
    b = Building.new
    b.architects = architects
    assert_equal architects, b.architects
    assert b.architects_changed?
  end
  
  def test_question_mark_method
    b = Building.new architects: %W{Bob John}
    assert_equal true, b.architects?
  end

  def test_persistence
    b = Building.new name: 'Test', stories: 5, architects: %W{Bob John}
    assert b.save
    assert_equal b.architects, Building.find(b.id).architects
  end
end
