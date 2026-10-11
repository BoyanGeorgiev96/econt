# frozen_string_literal: true

RSpec.describe 'Econt request parameter coverage' do
  let(:response) { Struct.new(:body).new({}) }

  it 'forwards every nomenclature filter' do
    service = Econt::Services::Nomenclatures::Nomenclatures.allocate

    city = Econt::Models::Nomenclatures::City.new(region_name: 'София', region_name_en: 'Sofia')
    allow(service).to receive(:get_cities).with(country_code: 'BGR').and_return([city])
    expect(service.get_regions(country_code: 'BGR', language: 'en')).to eq(['Sofia'])

    office_filters = {
      country_code: 'BGR', city_id: 41, show_cargo_receptions: true,
      show_lc: true, serving_receptions: true
    }
    expect_post(service, 'getOffices', office_filters)
    service.get_offices(**office_filters)
  end

  it 'forwards every address-service parameter' do
    service = Econt::Services::Nomenclatures::Address.allocate
    city = { id: 41, country: { code3: 'BGR' } }
    address = { city: city, street: 'Vitosha', num: '1' }

    expect_post(service, 'addressServiceTimes', {
                  city: city, address: address, date: '2026-10-12', shipment_type: 'pack'
                })
    service.address_service_times(
      city: city, address: address, date: '2026-10-12', shipment_type: 'pack'
    )

    expect_post(service, 'getNearestOffices', address: address, shipment_type: 'pack')
    service.get_nearest_offices(address: address, shipment_type: 'pack')
  end

  it 'forwards every documented courier-request field' do
    service = Econt::Services::Shipments::Shipment.allocate
    attributes = {
      request_time_from: '2026-10-12T10:00:00+03:00',
      request_time_to: '2026-10-12T12:00:00+03:00',
      shipment_type: 'pack', shipment_pack_count: 2, shipment_weight: 3.5,
      sender_client: { name: 'Sender' }, sender_agent: { name: 'Agent' },
      sender_address: { city: { id: 41 } }, attach_shipments: %w[123 456],
      pack12: 1, cargo_vehicle_options: { option: 'tail_lift' }
    }

    expect_post(service, 'requestCourier', attributes)
    service.request_courier(**attributes)
  end

  it 'forwards every label update parameter' do
    service = Econt::Services::Shipments::Label.allocate
    attributes = {
      label: { shipment_number: '123' },
      request_courier_time_from: '10:00', request_courier_time_to: '12:00',
      destroy: false, payment_addition_price: { amount: 1.25 },
      payment_instruction: { method: 'cash' }
    }

    expect_post(service, 'updateLabel', attributes)
    service.update_label(**attributes)
  end

  def expect_post(service, path, expected_body)
    expect(service).to receive(:post).with(path, body: expected_body).and_return(response)
    allow(service).to receive(:resource)
    allow(service).to receive(:collection)
  end
end
