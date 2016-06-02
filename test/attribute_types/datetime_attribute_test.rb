require_relative './../test_helper'

class DatetimeAttributeTest < MiniTest::Test

  def test_attribute_on_model_init
    approved_at = Time.now
    po = PurchaseOrder.new approved_at: approved_at
    assert_equal approved_at, po.approved_at
  end

  def test_attribute_on_existing_model
    approved_at = Time.now
    po = PurchaseOrder.new
    po.approved_at = approved_at
    assert_equal approved_at, po.approved_at
    assert po.approved_at_changed?
  end

  def test_question_mark_method
    approved_at = Time.now
    po = PurchaseOrder.new approved_at: approved_at
    assert_equal true, po.approved_at?
  end

  # Type conversion doesn't make sense here...
end
