# frozen_string_literal: true

require 'yaml'
require 'uri'
require_relative 'response_properties'
require_relative 'response_examples'

module RecordedResponses
  include ResponseProperties

  ROOT = File.expand_path('../fixtures/vcr_cassettes', __dir__)
  FILES = Dir[File.join(ROOT, '**/*.yml')].freeze
  UNWRAP = {
    'getCountries' => 'countries', 'getCities' => 'cities', 'getOffices' => 'offices',
    'getStreets' => 'streets', 'getQuarters' => 'quarters', 'getNearestOffices' => 'offices',
    'getClientProfiles' => 'profiles', 'createLabels' => 'results', 'deleteLabels' => 'results',
    'getShipmentStatuses' => 'shipmentStatuses'
  }.freeze

  def archived_interactions(file)
    YAML.safe_load_file(file, permitted_classes: [Time], aliases: false).fetch('http_interactions')
  end

  def replay_client
    client = Econt::Client.new
    client.username = 'cassette-replay'
    client.password = 'cassette-replay'
    client.setup_connection!
    client
  end

  def replay_interaction(interaction, client)
    path = URI.parse(interaction.fetch('request').fetch('uri')).path.delete_prefix('/ee/services')
    schema = ResponseExamples::MANIFEST.fetch('endpoints').fetch(path)
    service, operation = recorded_service(path, client)
    arguments = request_arguments(archived_body(interaction, 'request'))
    actual = call_recorded_service(service, operation, arguments)
    assert_recorded_result(actual, archived_body(interaction, 'response'), schema, operation)
  end

  def archived_body(interaction, side)
    JSON.parse(interaction.fetch(side).fetch('body').fetch('string'))
  end

  def recorded_service(path, client)
    service_path, operation = path.delete_prefix('/').delete_suffix('.json').split('Service.')
    group, service_name = service_path.split('/')
    service = Econt::Services.const_get(group, false).const_get(service_name, false).new(client: client)
    [service, operation]
  end

  def request_arguments(raw)
    case raw
    when Hash then raw.to_h { |key, value| [response_reader(key).to_sym, request_arguments(value)] }
    when Array then raw.map { |value| request_arguments(value) }
    else raw
    end
  end

  def call_recorded_service(service, operation, arguments)
    method = response_reader(operation)
    expect(service.class.instance_methods(false)).to include(method.to_sym)
    return service.validate_address(arguments.fetch(:address)) if operation == 'validateAddress'

    service.public_send(method, **arguments)
  end

  def assert_recorded_result(actual, raw, schema, operation)
    schema = resolved_schema(schema)
    if UNWRAP.key?(operation)
      key = UNWRAP.fetch(operation)
      raw = raw.fetch(key)
      schema = schema.fetch('properties').fetch(key)
    elsif operation == 'PaymentReport' && raw.key?('PaymentReportRows')
      raw = raw.fetch('PaymentReportRows') || []
      schema = { 'type' => 'array', 'items' => schema }
    end
    assert_recorded_shape(actual, raw, schema)
  end

  def assert_recorded_shape(actual, raw, schema)
    if schema['type'] == 'array'
      expect(actual).to be_a(Econt::Collection)
      actual = actual.to_a
    end
    assert_response_properties(actual, documented_properties(raw, schema), schema, ResponseExamples::SCHEMAS)
  end

  def resolved_schema(schema)
    return schema unless schema.key?('$ref')

    ResponseExamples::SCHEMAS.fetch(schema.fetch('$ref').split('/').last)
  end

  # Recorded responses may omit optional properties or include undocumented ones.
  # The documented unknown-field policy ignores the latter; every present,
  # documented property still receives the independent recursive reader check.
  def documented_properties(raw, schema)
    schema = resolved_schema(schema)
    case raw
    when Hash
      raw.slice(*schema.fetch('properties').keys).to_h do |key, value|
        [key, documented_properties(value, schema.fetch('properties').fetch(key))]
      end
    when Array then raw.map { |value| documented_properties(value, schema.fetch('items')) }
    else raw
    end
  end

  def assert_example_properties(raw, schema, path)
    expect(raw.keys - schema.fetch('properties', {}).keys).to eq([]), "#{path}: unknown documented properties"
  end

  def assert_response_properties(actual, raw, schema, schemas, path = '$')
    if raw.is_a?(Numeric) && schema['type'] == 'string' && schema['format'] == 'time'
      expect(actual).to eq(raw.to_s), "#{path}: documented string coercion differs"
    else
      super
    end
  end

  def documented_scalar(raw, format)
    return raw if raw.is_a?(Numeric) # Numeric timestamp units remain undocumented.
    return raw if raw.is_a?(String) && raw.start_with?('<') # Sanitizer placeholders are deliberately non-date values.

    super
  end
end
