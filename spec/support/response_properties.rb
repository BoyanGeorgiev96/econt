# frozen_string_literal: true

module ResponseProperties
  # Independent tokenization; numbers stay within their word (code2, next30days),
  # while an uppercase letter following a digit starts a new word (step2Name).
  def response_reader(key)
    key.to_s.scan(/[A-Z]+(?=[A-Z][a-z]|\d|\z)|[A-Z]?[a-z]+\d*[a-z]*|\d+/).join('_').downcase
  end

  def assert_response_properties(actual, raw, schema, schemas, path = '$')
    schema = schemas.fetch(schema.fetch('$ref').split('/').last) if schema.key?('$ref')
    case raw
    when Hash
      assert_object_properties(actual, raw, schema, schemas, path)
    when Array
      assert_array_properties(actual, raw, schema, schemas, path)
    else
      expected = documented_scalar(raw, schema['format'])
      expect(actual).to eq(expected), "#{path}: expected #{expected.inspect}, got #{actual.inspect}"
    end
  end

  def assert_object_properties(actual, raw, schema, schemas, path)
    assert_example_properties(raw, schema, path)
    assert_object_shape(actual, raw, path)
    raw.each do |key, value|
      assert_reader_property(actual, key, value, schema, schemas, path)
    end
  end

  def assert_example_properties(raw, schema, path)
    expect(raw.keys).to match_array(schema.fetch('properties', {}).keys), "#{path}: documented properties missing"
  end

  def assert_object_shape(actual, raw, path)
    expect(actual).not_to be_a(Hash), "#{path}: expected dot-accessible model, got a raw hash"
    expect(actual).to respond_to(:to_h), "#{path}: expected a response model"
    expect(actual.to_h).to eq({}) if raw.empty?
  end

  def assert_reader_property(actual, key, value, schema, schemas, path)
    reader = response_reader(key)
    expect(actual).to respond_to(reader), "#{path}.#{key}: missing .#{reader}"
    child_schema = schema.fetch('properties').fetch(key)
    assert_response_properties(actual.public_send(reader), value, child_schema, schemas, "#{path}.#{key}")
  end

  def assert_array_properties(actual, raw, schema, schemas, path)
    expect(actual).to respond_to(:size, :[]), "#{path}: expected an array"
    expect(actual.size).to eq(raw.size), "#{path}: array length changed"
    raw.each_with_index do |value, index|
      assert_response_properties(actual[index], value, schema.fetch('items'), schemas, "#{path}[#{index}]")
    end
  end

  def documented_scalar(raw, format)
    return nil if raw.nil?

    case format
    when 'date' then Date.iso8601(raw)
    when 'date-time' then DateTime.iso8601(raw)
    else raw
    end
  end
end
