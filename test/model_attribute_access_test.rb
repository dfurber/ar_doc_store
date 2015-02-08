require_relative './test_helper'

class ModelAttributeAccessTest < MiniTest::Test
  def test_string_attribute_on_model_init
    b = Building.new name: 'test'
    assert_equal 'test', b.name
  end

  def test_string_attribute_on_existing_model
    b = Building.new
    b.name = 'test'
    assert_equal 'test', b.name
  end
  
  def test_boolean_attribute_on_model_init
    b = Building.new finished: true
    assert b.finished?
  end
  
  def test_boolean_attribute_on_existing_model
    b = Building.new
    b.finished = true
    assert b.finished?
  end
  
  def test_float_attribute_on_init
    b = Building.new height: 54.45
    assert_equal 54.45, b.height
  end
  
  def test_float_attribute_on_existing_model
    b = Building.new
    b.height = 54.45
    assert_equal 54.45, b.height
  end
  
  def test_int_attribute_on_init
    b = Building.new stories: 5
    assert_equal 5, b.stories
  end
  
  def test_int_attribute_on_set
    b = Building.new
    b.stories = 5
    assert_equal 5, b.stories
  end
  
  def test_simple_enumeration_attribute
    b = Building.new construction: 'wood'
    assert_equal 'wood', b.construction
  end
  
  def test_multiple_enumeration_attribute
    b = Building.new multiconstruction: %w{wood plaster}
    assert_equal %w{wood plaster}, b.multiconstruction
  end

  def test_strict_enumeration_attribute_invalid
    b = Building.new strict_enumeration: 'wood'
    b.valid?
    assert b.errors[:strict_enumeration]
  end
  
  def test_unstrict_enumeration_attribute_allows_assignment_of_choice_not_in_the_list
    b = Building.new construction: 'plastic'
    assert_equal 'plastic', b.construction
    b.valid?
    assert b.errors[:construction].empty?
  end

  def test_unstrict_multi_enumeration_attribute_allows_assignment_of_choice_not_in_the_list
    b = Building.new multiconstruction: %w{plastic wood}
    assert_equal %w{plastic wood}, b.multiconstruction
    b.valid?
    assert b.errors[:multiconstruction].empty?
  end

  def test_strict_multi_enumeration_attribute_invalid
    b = Building.new strict_multi_enumeration: %w{good wood}
    b.valid?
    assert b.errors[:strict_multi_enumeration]
  end

  def test_strict_enumeration_attribute_valid
    b = Building.new strict_enumeration: 'glad'
    b.valid?
    assert b.errors[:strict_enumeration].empty?
  end

  def test_strict_multi_enumeration_attribute_valid
    b = Building.new strict_multi_enumeration: %w{glad bad}
    b.valid?
    assert b.errors[:strict_multi_enumeration].empty?
  end
  
  def test_enumeration_has_choices_to_use_for_select
    assert Building.construction_choices.present?
  end
    
end
