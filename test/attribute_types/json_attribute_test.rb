require_relative './../test_helper'

class JsonAttributeTest < MiniTest::Test
  
  def api_response
    {
      'droplet' => {
        'id' => 4324242,
        'name' => 'eternal-droplet',
        'size' => 64,
        'regions' => ['ny1', 'ny2', 'ny3']
      }
    }
  end
  
  def test_attribute_on_model_init
    b = Building.new api_response: api_response
    assert_equal Hashie::Mash.new(api_response), b.api_response
  end

  def test_attribute_on_existing_model
    b = Building.new
    b.api_response = api_response
    assert_equal Hashie::Mash.new(api_response), b.api_response
    assert b.api_response_changed?
  end
  
  def test_question_mark_method
    b = Building.new api_response: api_response
    assert_equal true, b.api_response?
  end
  
  # def test_type_conversion_on_init
  #   b = Building.new api_response: api_response
  #   assert_equal Hashie::Mash.new(api_response), b.api_response
  # end
  
  def test_type_conversion_on_existing
    b = Building.new 
    b.stories = '5'
    assert_equal 5, b.stories
  end
  
end
