class JsonAttribute < ArDocStore::AttributeTypes::Base
  def conversion
    Hashie::Mash
  end

  def predicate
    'jsonb'
  end

  def type
    :object
  end
end
