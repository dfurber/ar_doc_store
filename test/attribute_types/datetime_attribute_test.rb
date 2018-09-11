require_relative './../test_helper'

class DatetimeAttributeTest < MiniTest::Test

  def test_attribute_on_model_init
    inspected_at = Time.new(1984, 3, 6)
    b = Building.new inspected_at: inspected_at
    assert inspected_at == b.inspected_at
  end

  def test_attribute_on_existing_model
    inspected_at = Time.new(1984, 3, 6)
    b = Building.new
    b.inspected_at = inspected_at
    assert inspected_at == b.inspected_at
    assert b.inspected_at_changed?
  end

  def test_question_mark_method
    inspected_at = Time.new(1984, 3, 6)
    b = Building.new inspected_at: inspected_at
    assert_equal true, b.inspected_at?
  end

  def test_conversion
    inspected_at = Time.new(1984, 3, 6)
    b = Building.new inspected_at: inspected_at.to_s
    assert_kind_of Time, b.inspected_at
  end

  def test_no_op
    b = Building.new
    assert_nil b.inspected_at
  end

  def test_multiparameter_assignment
    inspected_at = {
        "inspected_at(2i)" => "4",
        "inspected_at(4i)" => "12",
        "inspected_at(1i)" => "2014",
        "inspected_at(3i)" => "21",
        "inspected_at(5i)" => "53",
    }
    b = Building.new inspected_at
    assert_equal DateTime.new(2014, 4, 21, 12, 53), b.inspected_at
  end

  def test_persistence
    inspected_at = DateTime.new(2014, 4, 21, 12, 53)
    b = Building.new inspected_at: inspected_at
    assert b.save
    assert_equal DateTime.new(2014, 4, 21, 12, 53), Building.find(b.id).inspected_at
  end
end
