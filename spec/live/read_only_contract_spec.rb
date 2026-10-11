# frozen_string_literal: true

RSpec.describe 'Econt read-only API contracts', :live do
  around do |example|
    VCR.use_cassette(example.metadata.fetch(:cassette)) { example.run }
  end

  before do
    Econt::Client.configure do |config|
      config.username = ENV.fetch('ECONT_USERNAME')
      config.password = ENV.fetch('ECONT_PASSWORD')
      config.base_url = ENV.fetch('ECONT_BASE_URL', 'http://demo.econt.com/ee/services/')
    end
  end

  let(:country_code) { ENV.fetch('ECONT_CONTRACT_COUNTRY_CODE', 'BGR') }
  let(:city_id) { Integer(ENV.fetch('ECONT_CONTRACT_CITY_ID', '41'), 10) }
  let(:address) do
    {
      city: { id: city_id, country: { code3: country_code } },
      street: 'бул. Витоша',
      num: '1'
    }
  end

  it 'loads address service times', cassette: 'econt_demo/address_service_times' do
    result = addresses.address_service_times(
      city: address.fetch(:city),
      address: address,
      date: contract_date,
      shipment_type: 'pack'
    )

    expect(result).to be_a(Econt::Models::Nomenclatures::AddressServiceTimesResponse)
    expect(result.service_office).to be_a(Econt::Models::Nomenclatures::Office)
  end

  it 'loads sanitized client profiles', cassette: 'econt_demo/client_profiles' do
    profiles = Econt::Services::Profile::Profile.new.get_client_profiles

    expect(profiles).not_to be_empty
    expect(profiles.first).to be_a(Econt::Models::Profile::ProfilesResponseElement)
  end

  it 'calculates a label without creating it', cassette: 'econt_demo/label_calculation' do
    result = labels.create_label(mode: 'calculate', label: synthetic_label)

    expect(result).to be_a(Econt::Models::Shipments::CreateLabelResultElement)
    expect(result).not_to be_error
    expect(result.label).to be_a(Econt::Models::Shipments::ShipmentStatus)
  end

  it 'validates a label without creating it', cassette: 'econt_demo/label_validation' do
    result = labels.create_label(mode: 'validate', label: synthetic_label)

    expect(result).to be_a(Econt::Models::Shipments::CreateLabelResultElement)
    expect(result).not_to be_error
  end

  it 'validates labels in bulk without creating them', cassette: 'econt_demo/labels_validation' do
    results = labels.create_labels(mode: 'validate', labels: [synthetic_label])

    expect(results).to all(be_a(Econt::Models::Shipments::CreateLabelResultElement))
    expect(results).to all(satisfy { |result| !result.error? })
  end

  it 'loads a sanitized payment report', cassette: 'econt_demo/payment_report' do
    report = Econt::Services::PaymentReport::PaymentReport.new.payment_report(
      date_from: contract_date,
      date_to: contract_date
    )

    expect(report).to be_a(Econt::Models::PaymentReport::PaymentReportRow)
  end

  it 'loads sanitized AWB history', cassette: 'econt_demo/my_awb' do
    response = shipments.get_my_awb(date_from: contract_date, date_to: contract_date, page: 1)

    expect(response).to be_a(Econt::Models::Shipments::GetMyAwbResponse)
  end

  it 'loads shipment statuses when fixture numbers are configured', cassette: 'econt_demo/shipment_statuses' do
    numbers = configured_list('ECONT_CONTRACT_SHIPMENT_NUMBERS')
    skip 'Set ECONT_CONTRACT_SHIPMENT_NUMBERS to record this read-only contract' if numbers.empty?

    statuses = shipments.get_shipment_statuses(shipment_numbers: numbers)

    expect(statuses).not_to be_empty
    expect(statuses.first).to be_a(Econt::Models::Shipments::ShipmentStatusResultElement)
  end

  it 'checks possible editions when fixture numbers are configured', cassette: 'econt_demo/shipment_editions' do
    numbers = configured_list('ECONT_CONTRACT_SHIPMENT_NUMBERS').map { |number| Integer(number, 10) }
    skip 'Set ECONT_CONTRACT_SHIPMENT_NUMBERS to record this read-only contract' if numbers.empty?

    results = labels.check_possible_shipment_editions(shipment_nums: numbers)

    expect(results).to all(be_a(Econt::Models::Shipments::CheckPossibleShipmentEditionsResultElement))
  end

  it 'loads courier-request statuses when fixture ids are configured', cassette: 'econt_demo/courier_statuses' do
    ids = configured_list('ECONT_CONTRACT_COURIER_REQUEST_IDS').map { |id| Integer(id, 10) }
    skip 'Set ECONT_CONTRACT_COURIER_REQUEST_IDS to record this read-only contract' if ids.empty?

    statuses = shipments.get_request_courier_status(request_courier_ids: ids)

    expect(statuses).to all(be_a(Econt::Models::Shipments::RequestCourierStatusResultElement))
  end

  def addresses
    @addresses ||= Econt::Services::Nomenclatures::Address.new
  end

  def labels
    @labels ||= Econt::Services::Shipments::Label.new
  end

  def shipments
    @shipments ||= Econt::Services::Shipments::Shipment.new
  end

  def contract_date
    ENV.fetch('ECONT_CONTRACT_SERVICE_DATE', '').then do |value|
      value.empty? ? Date.today.iso8601 : value
    end
  end

  def configured_list(key)
    ENV.fetch(key, '').split(',').map(&:strip).reject(&:empty?)
  end

  def synthetic_label
    {
      sender_client: { name: 'VCR Sender', phones: ['+359888000000'] },
      sender_address: address,
      receiver_client: { name: 'VCR Receiver', phones: ['+359888000001'] },
      receiver_office_code: '1000',
      shipment_type: 'pack',
      pack_count: 1,
      weight: 1.0,
      shipment_description: 'VCR contract test',
      services: {}
    }
  end
end
