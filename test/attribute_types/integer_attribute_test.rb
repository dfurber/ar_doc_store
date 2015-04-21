require_relative './../test_helper'

class IntegerAttributeTest < MiniTest::Test
  
  def test_string_attribute_on_model_init
    b = Building.new stories: 5
    assert_equal 5, b.stories
  end

  def test_string_attribute_on_existing_model
    b = Building.new
    b.stories = 5
    assert_equal 5, b.stories
    assert b.stories_changed?
  end
  
  def test_question_mark_method
    b = Building.new stories: 5
    assert_equal true, b.stories?
  end
  
  def test_type_conversion_on_init
    b = Building.new stories: '5'
    assert_equal 5, b.stories
  end
  
  def test_type_conversion_on_existing
    b = Building.new 
    b.stories = '5'
    assert_equal 5, b.stories
  end
  
end
