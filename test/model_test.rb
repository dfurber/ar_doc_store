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

  def test_ransack_finds_string
    Building.create name: 'test'
    search = Building.ransack(name_eq: 'test').result
    assert search.size > 0
  end

  def test_ransack_finds_array
    Building.create multiconstruction: %w[brick wood]
    # search = Building.construction_in(['brick'])
    search = Building.ransack(multiconstruction_jin: ['brick', 'wood']).result
    puts search.to_sql
    assert search.size > 0
  end
end
