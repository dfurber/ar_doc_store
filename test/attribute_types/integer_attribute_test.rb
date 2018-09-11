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

  def test_numeric_validation
    b = Building.new
    b.stories = 5
    assert b.valid?
  end

  def test_persistence
    b = Building.new name: 'Test', stories: 5
    assert b.save
    assert_equal 5, Building.find(b.id).stories
  end

  def test_default_value
    b = Building.new
    assert_equal 12, b.number_with_default
  end

  def test_dirty_on_init
    b = Building.new name: 'Foo'
    assert b.name_changed?
  end

  def test_dirty_persisted
    a = Building.create name: 'Foo'
    b = Building.find a.id
    assert !b.name_changed?
    b.name = 'Bar'
    assert b.name_changed?
    assert_equal 'Foo', b.name_was
  end
end
