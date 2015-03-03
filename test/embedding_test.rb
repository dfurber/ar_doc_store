require_relative './test_helper'

class EmbeddingTest < MiniTest::Test
  
  def test_can_build_embedded_model
    restroom = Restroom.new
    door = restroom.build_door
    assert door.is_a?(Door)
  end
  
  def test_ensure_door_returns_existing_door
    restroom = Restroom.new
    restroom.build_door
    restroom.door.open_handle = %w{knob}
    restroom.ensure_door
    assert_equal %w{knob}, restroom.door.open_handle
  end
  
  def test_attributes_equals_sets_attributes
    restroom = Restroom.new door_attributes: { clear_distance: 5, opening_force: 13, clear_space: 43 }
    assert_equal 5, restroom.door.clear_distance
    restroom.door_attributes = { _destroy: '1' }
    assert_nil restroom.door.clear_distance
  end
  
  def test_attributes_equals_sets_partial_attributes
    restroom = Restroom.new door_attributes: { clear_distance: 5, opening_force: 13, clear_space: 43 }
    restroom.door_attributes = { clear_distance: 7 }
    assert_equal 7, restroom.door.clear_distance
    assert_equal 13, restroom.door.opening_force
  end
  
  def test_embeds_many_attributes_equals_sets_partial_attributes
    building = Building.new
    building.restrooms << Restroom.new(door_attributes: { clear_distance: 5, opening_force: 13, clear_space: 43 })
    building.restrooms << Restroom.new(door_attributes: { clear_distance: 6, opening_force: 14, clear_space: 44 })
    building.restrooms << Restroom.new(door_attributes: { clear_distance: 7, opening_force: 15, clear_space: 45 })
    restrooms_attributes = {
      a1: { id: building.restrooms[0].id, door_attributes: { clear_distance: 10 } },
      a2: { id: building.restrooms[1].id, _destroy: true },
      a3: { id: building.restrooms[2].id, door_attributes: { clear_distance: 1 } }
    }
    building.restrooms_attributes = restrooms_attributes
    assert_equal 2, building.restrooms.size
    assert_equal 10, building.restrooms.first.door.clear_distance
    assert_equal 15, building.restrooms.last.door.opening_force
    assert_equal 1, building.restrooms.last.door.clear_distance
    assert_nil building.restrooms.detect {|restroom| restroom.id == restrooms_attributes[:a2][:id] }
  end
  
  def test_attribute_validity_of_embedded_model_from_model
    b = Building.new
    r = Restroom.new
    b.restrooms << r
    assert !b.valid?
  end

  def test_model_with_no_attributes
    item = ThingWithEmptyModel.new
    item.build_empty_model
    assert item.empty_model.is_a?(EmptyModel)
  end

  def test_model_subclassing
    assert_equal EmbeddableB.virtual_attributes.size, 3
  end

end