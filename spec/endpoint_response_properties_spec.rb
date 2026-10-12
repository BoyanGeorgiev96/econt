# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/response_properties'
require_relative 'support/response_examples'

module ResponseExamples
  SERVICES = {
    'PaymentReport/PaymentReport' => Econt::Services::PaymentReport::PaymentReport,
    'ThreeWayLogistics/ThreeWayLogistics' => Econt::Services::ThreeWayLogistics::ThreeWayLogistics,
    'Profile/Profile' => Econt::Services::Profile::Profile,
    'Shipments/Label' => Econt::Services::Shipments::Label,
    'Shipments/Shipment' => Econt::Services::Shipments::Shipment,
    'Nomenclatures/Nomenclatures' => Econt::Services::Nomenclatures::Nomenclatures,
    'Nomenclatures/Address' => Econt::Services::Nomenclatures::Address
  }.freeze

  # Explicit reader names also make unusual acronym boundaries reviewable.
  ENDPOINTS = {
    'PaymentReport' => [:payment_report, {}, nil],
    'threeWayLogistics' => [:three_way_logistics, {}, nil],
    'getClientProfiles' => [:get_client_profiles, {}, 'profiles'],
    'createCDAgreement' => [:create_cd_agreement, { cd_pay_options: {} }, 'cdPayOptions'],
    'createLabel' => [:create_label, {}, nil],
    'createLabels' => [:create_labels, {}, 'results'],
    'deleteLabels' => [:delete_labels, {}, 'results'],
    'updateLabel' => [:update_label, {}, nil],
    'checkPossibleShipmentEditions' => [:check_possible_shipment_editions, {}, 'possibleShipmentEditions'],
    'updateLabels' => [:update_labels, {}, 'results'],
    'grouping' => [:grouping, {}, 'label'],
    'groupingCancelation' => [:grouping_cancelation, {}, nil],
    'requestCourier' => [:request_courier, {}, nil],
    'getShipmentStatuses' => [:get_shipment_statuses, {}, 'shipmentStatuses'],
    'getRequestCourierStatus' => [:get_request_courier_status, {}, 'requestCourierStatus'],
    'getMyAWB' => [:get_my_awb, {}, nil],
    'setITUCode' => [:set_itu_code, { awb_barcode: 'synthetic', truck_reg_num: 'synthetic', itu_code: 'test' }, :raw],
    'getCountries' => [:get_countries, {}, 'countries'],
    'getCities' => [:get_cities, { country_code: 'BGR' }, 'cities'],
    'getOffices' => [:get_offices, { country_code: 'BGR' }, 'offices'],
    'getStreets' => [:get_streets, {}, 'streets'],
    'getQuarters' => [:get_quarters, {}, 'quarters'],
    'validateAddress' => [:validate_address, {}, nil],
    'addressServiceTimes' => [:address_service_times,
                              { city: {}, address: {}, date: '2026-10-11', shipment_type: 'pack' }, nil],
    'getNearestOffices' => [:get_nearest_offices, { address: {}, shipment_type: 'pack' }, 'offices']
  }.freeze
end

RSpec.describe 'endpoint response properties' do
  include ResponseProperties
  include ResponseExamples

  ResponseExamples::MANIFEST.fetch('endpoints').each do |path, schema|
    [false, true].each do |null_scalars|
      it "exposes every documented response property for #{path} (null scalars: #{null_scalars})" do
        service_key, endpoint = path.delete_prefix('/').delete_suffix('.json').split('Service.')
        method, arguments, unwrap = ResponseExamples::ENDPOINTS.fetch(endpoint)
        client = Econt::Client.new
        client.username = 'offline-example'
        client.password = 'offline-example'
        client.setup_connection!
        service = ResponseExamples::SERVICES.fetch(service_key).new(client: client)
        variant = null_scalars ? 'null_scalars' : 'success'
        raw = response_example("#{endpoint}/#{variant}")
        stub_request(:post, "https://demo.econt.com/ee/services#{path}")
          .to_return(status: 200, body: JSON.generate(raw), headers: { 'Content-Type' => 'application/json' })
        result = endpoint == 'validateAddress' ? service.validate_address({}) : service.public_send(method, **arguments)
        assert_endpoint_properties(result, raw, schema, unwrap)
      end
    end

    it "exposes every documented error property for #{path}" do
      service_key, endpoint = path.delete_prefix('/').delete_suffix('.json').split('Service.')
      method, arguments, = ResponseExamples::ENDPOINTS.fetch(endpoint)
      client = Econt::Client.new
      client.username = 'offline-example'
      client.password = 'offline-example'
      client.setup_connection!
      service = ResponseExamples::SERVICES.fetch(service_key).new(client: client)
      raw = response_example('error')
      stub_request(:post, "https://demo.econt.com/ee/services#{path}")
        .to_return(status: 400, body: JSON.generate(raw), headers: { 'Content-Type' => 'application/json' })
      result = endpoint == 'validateAddress' ? service.validate_address({}) : service.public_send(method, **arguments)
      if endpoint == 'setITUCode'
        expect(result.body).to eq(raw)
      else
        expect(result).to be_error
        assert_response_properties(result.error, raw, ResponseExamples::SCHEMAS.fetch('Error'), ResponseExamples::SCHEMAS)
      end
    end
  end

  it 'has a response example for every service endpoint' do
    exposed = ResponseExamples::SERVICES.values.flat_map { |service| service.instance_methods(false) }
    expect(ResponseExamples::ENDPOINTS.values.map(&:first) + [:get_regions]).to match_array(exposed)
    expect(ResponseExamples::MANIFEST.fetch('endpoints').size).to eq(ResponseExamples::ENDPOINTS.size)
  end

  it 'derives sorted unique regions from documented city readers in both languages' do
    client = Econt::Client.new
    client.username = 'offline-example'
    client.password = 'offline-example'
    client.setup_connection!
    service = Econt::Services::Nomenclatures::Nomenclatures.new(client: client)
    cities = [{ regionName: 'Пловдив', regionNameEn: 'Plovdiv' },
              { regionName: 'Варна', regionNameEn: 'Varna' },
              { regionName: 'Пловдив', regionNameEn: 'Plovdiv' },
              { regionName: nil, regionNameEn: nil }]
    stub_request(:post, 'https://demo.econt.com/ee/services/Nomenclatures/NomenclaturesService.getCities.json')
      .to_return(status: 200, body: JSON.generate(cities: cities), headers: { 'Content-Type' => 'application/json' })
    expect(service.get_regions(country_code: 'BGR')).to eq(%w[Варна Пловдив])
    expect(service.get_regions(country_code: 'BGR', language: 'en')).to eq(%w[Plovdiv Varna])
  end

  def assert_endpoint_properties(result, raw, schema, unwrap)
    if unwrap == :raw
      expect(result.body).to eq(raw) # setITUCode deliberately returns a raw Faraday response.
      return
    end
    if unwrap
      schema = ResponseExamples::SCHEMAS.fetch(schema.fetch('$ref').split('/').last).fetch('properties').fetch(unwrap)
      raw = raw.fetch(unwrap)
    end
    result = result.to_a if result.is_a?(Econt::Collection)
    assert_response_properties(result, raw, schema, ResponseExamples::SCHEMAS)
  end
end
