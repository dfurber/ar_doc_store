require_relative './test_helper'

class ModelTest < MiniTest::Test
  def test_save_with_validation
    b = Building.new name: 'test'
    assert b.save
    b.reload
    assert_equal 'test', b.name
  end

  def test_save_without_validation
    b = Building.new name: 'test'
    assert b.save(validate: false)
    b.reload
    assert_equal 'test', b.name
  end
end
