require_relative './../test_helper'

class EmbeddedModelAttributeTest < MiniTest::Test
  
  def test_can_set_attribute_on_embedded_model_init
    b = Route.new route_surface: 'test'
    assert_equal 'test', b.route_surface
  end
  
  def test_can_set_attribute_on_existing_embedded_model
    b = Route.new
    b.route_surface = 'test'
    assert_equal 'test', b.route_surface
  end
  
  def test_can_set_enumeration_created_with_enumerates
    door = Door.new
    door.door_type = %w{sliding push}
    assert_equal %w{sliding push}, door.door_type
  end

end

