require_relative './../test_helper'

class BooleanAttributeTest < MiniTest::Test
  
  def test_attribute_on_model_init
    b = Building.new finished: true
    assert_equal true, b.finished
  end

  def test_attribute_on_existing_model
    b = Building.new
    b.finished = true
    assert_equal true, b.finished
    assert b.finished_changed?
  end
  
  def test_question_mark_method
    b = Building.new finished: true
    assert_equal true, b.finished?
  end

  # The setter function doesn't appear to get called in this context.
  # But more likely traces to ARDuck.
  # TODO: Does this still fail after replacing ARDuck with AR::Base?
  def test_type_conversion_on_init
    b = Building.new finished: '1'
    assert_equal true, b.finished
  end

  def test_type_conversion_on_existing
    b = Building.new
    b.finished = '1'
    assert_equal true, b.finished
  end
  
end
