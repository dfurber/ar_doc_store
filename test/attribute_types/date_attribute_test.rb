require_relative './../test_helper'

class DateAttributeTest < MiniTest::Test

  def test_attribute_on_model_init
    finished_on = Date.new(1984, 3, 6)
    b = Building.new finished_on: finished_on
    assert finished_on == b.finished_on
  end

  def test_attribute_on_existing_model
    finished_on = Date.new(1984, 3, 6)
    b = Building.new
    b.finished_on = finished_on
    assert finished_on == b.finished_on
    assert b.finished_on_changed?
  end

  def test_question_mark_method
    finished_on = Date.new(1984, 3, 6)
    b = Building.new finished_on: finished_on
    assert_equal true, b.finished_on?
  end

  def test_conversion
    finished_on = Date.new(1984, 3, 6)
    b = Building.new finished_on: finished_on.to_s
    assert_kind_of Date, b.finished_on
  end

  def test_no_op
    b = Building.new
    assert_nil b.finished_on
  end
  
  def test_multiparameter_assignment
    finished_on = {
        "finished_on(2i)" => "4",
        "finished_on(1i)" => "2014",
        "finished_on(3i)" => "21",
    }
    b = Building.new finished_on
    assert_equal Date.new(2014, 4, 21), b.finished_on
  end

  def test_persistence
    finished_on = Date.new(2014, 4, 21)
    b = Building.new finished_on: finished_on
    assert b.save
    assert_equal Date.new(2014, 4, 21), Building.find(b.id).finished_on
  end
end
