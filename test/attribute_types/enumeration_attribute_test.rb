require_relative './../test_helper'

class EnumerationAttributeTest < MiniTest::Test
  
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

  def test_question_mark_method
    b = Building.new strict_multi_enumeration: %w{glad bad}
    assert_equal true, b.strict_multi_enumeration?
  end

  def test_persistence
    b = Building.new name: 'Test', strict_multi_enumeration: %w{glad bad}
    assert b.save
    assert_equal %w{glad bad}, Building.find(b.id).strict_multi_enumeration
  end
end
