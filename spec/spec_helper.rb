# frozen_string_literal: true

require 'base64'
require 'date'
require 'dotenv'
require 'json'
require 'vcr'
require 'webmock/rspec'

ECONT_REPLAY_ONLY = ENV['ECONT_VCR_REPLAY'] == '1' || ENV['CI'] == 'true'
Dotenv.load('.env.test', '.env') unless ECONT_REPLAY_ONLY

require 'econt'

module EcontVcrSanitizer
  MUTATION_CASSETTE = 'econt_demo/label_create_and_delete'
  CREATED_SHIPMENT_PLACEHOLDER = '<ECONT_CREATED_SHIPMENT_NUMBER>'
  ACCOUNT_ENDPOINT = /
    getClientProfiles|getMyAWB|PaymentReport|getShipmentStatuses|
    getRequestCourierStatus|checkPossibleShipmentEditions|createLabel|updateLabel|deleteLabels
  /x
  SENSITIVE_KEY = /
    name|phone|email|address|street|quarter|other|zip|num|block|entrance|floor|apart|clientNumber|
    shipmentNumber|shipmentNum|awbBarcode|orderNumber|iban|bic|
    paymentToken|token|secret|url|(?:\A|_)key\z|amount|price|(?:\A|_)id\z|ID\z
  /ix

  module_function

  def sanitize_mutation!(interaction)
    if interaction.request.uri.include?('LabelService.createLabel')
      response = JSON.parse(interaction.response.body.to_s.dup.force_encoding(Encoding::UTF_8))
      @created_shipment_number = nested_value(response, 'shipmentNumber')
    end
    return if @created_shipment_number.to_s.empty?

    replace_in_bodies!(interaction, @created_shipment_number.to_s, CREATED_SHIPMENT_PLACEHOLDER)
    sanitize_response!(interaction)
  rescue JSON::ParserError
    nil
  end

  def sanitize_response!(interaction)
    return unless interaction.request.uri.match?(ACCOUNT_ENDPOINT)

    body = interaction.response.body.to_s.dup.force_encoding(Encoding::UTF_8)
    return if body.empty?

    interaction.response.body = JSON.pretty_generate(sanitize(JSON.parse(body)))
  rescue JSON::ParserError
    nil
  end

  def sanitize(value, key = nil)
    return redact(value) if key&.match?(SENSITIVE_KEY) && !value.is_a?(Hash) && !value.is_a?(Array)

    case value
    when Hash
      value.to_h { |child_key, child_value| [child_key, sanitize(child_value, child_key)] }
    when Array
      value.map { |item| sanitize(item, key) }
    else
      value
    end
  end

  def redact(value)
    return value if value == CREATED_SHIPMENT_PLACEHOLDER

    case value
    when Array then value.map { |item| redact(item) }
    when Numeric then 0
    when true, false then false
    when nil then nil
    else '<REDACTED>'
    end
  end

  def nested_value(value, key)
    return value[key] if value.is_a?(Hash) && value.key?(key)

    children = value.is_a?(Hash) ? value.values : Array(value)
    children.each do |child|
      result = nested_value(child, key) if child.is_a?(Hash) || child.is_a?(Array)
      return result if result
    end
    nil
  end

  def replace_in_bodies!(interaction, value, placeholder)
    [interaction.request, interaction.response].each do |message|
      message.body = message.body.to_s.gsub(value, placeholder)
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    record: ECONT_REPLAY_ONLY ? :none : :once,
    match_requests_on: %i[method uri body]
  }
  config.allow_http_connections_when_no_cassette = false
  config.before_http_request do |request|
    raise 'Network requests are forbidden during Econt cassette replay' if ECONT_REPLAY_ONLY && !request.stubbed?
  end

  %w[ECONT_USERNAME ECONT_PASSWORD].each do |key|
    value = ENV.fetch(key, nil)
    config.filter_sensitive_data("<#{key}>") { value } unless ECONT_REPLAY_ONLY || value.to_s.empty?
  end

  %w[
    ECONT_CONTRACT_SHIPMENT_NUMBERS
    ECONT_CONTRACT_COURIER_REQUEST_IDS
  ].each do |key|
    value = ENV.fetch(key, nil)
    next if ECONT_REPLAY_ONLY

    config.filter_sensitive_data("<#{key}>") { value } unless value.to_s.empty?
    value.to_s.split(',').map(&:strip).reject(&:empty?).each_with_index do |item, index|
      config.filter_sensitive_data("<#{key}_#{index + 1}>") { item }
    end
  end

  configured_date = ENV.fetch('ECONT_CONTRACT_SERVICE_DATE', '')
  contract_date = configured_date.empty? ? Date.today.iso8601 : configured_date
  config.filter_sensitive_data('<ECONT_CONTRACT_SERVICE_DATE>') { contract_date } unless ECONT_REPLAY_ONLY

  username = ENV.fetch('ECONT_USERNAME', nil)
  password = ENV.fetch('ECONT_PASSWORD', nil)
  if !ECONT_REPLAY_ONLY && [username, password].none? { |value| value.to_s.empty? }
    basic_token = Base64.strict_encode64("#{username}:#{password}")
    config.filter_sensitive_data('<ECONT_BASIC_TOKEN>') { basic_token }
  end

  config.before_record do |interaction, cassette|
    raise 'Recording is forbidden during Econt cassette replay' if ECONT_REPLAY_ONLY

    interaction.request.headers.delete_if do |key, _value|
      %w[authorization cookie].any? { |sensitive| key.casecmp(sensitive).zero? }
    end
    interaction.response.headers.delete_if { |key, _value| key.casecmp('set-cookie').zero? }
    if cassette.name == EcontVcrSanitizer::MUTATION_CASSETTE
      EcontVcrSanitizer.sanitize_mutation!(interaction)
    else
      EcontVcrSanitizer.sanitize_response!(interaction)
    end
  end
end

WebMock.disable_net_connect!
if ECONT_REPLAY_ONLY
  # VCR otherwise overrides WebMock's network policy while turned on.
  WebMock.singleton_class.prepend(Module.new do
    def net_connect_allowed?(*_arguments)
      false
    end
  end)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.filter_run_excluding live: true unless ENV['ECONT_LIVE_TESTS'] == '1'
  config.filter_run_excluding mutation: true unless ENV['ECONT_MUTATING_LIVE_TESTS'] == '1'
  config.filter_run_excluding replay: true unless ENV['ECONT_VCR_REPLAY'] == '1'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
