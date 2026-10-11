# frozen_string_literal: true

RSpec.describe 'Econt label mutation contract', :live, :mutation do
  around do |example|
    VCR.use_cassette('econt_demo/label_create_and_delete') { example.run }
  end

  before do
    Econt::Client.configure do |config|
      config.username = ENV.fetch('ECONT_USERNAME')
      config.password = ENV.fetch('ECONT_PASSWORD')
      config.base_url = ENV.fetch('ECONT_BASE_URL', 'http://demo.econt.com/ee/services/')
    end
  end

  it 'creates a synthetic label and deletes it during cleanup' do
    result = cleanup = verification = nil
    shipment_number = nil

    begin
      result = labels.create_label(mode: 'create', label: synthetic_label)
      shipment_number = result.label&.shipment_number unless result.error?
    ensure
      if shipment_number
        cleanup = labels.delete_labels(shipment_numbers: [shipment_number])
        verification = shipments.get_shipment_statuses(shipment_numbers: [shipment_number])
      end
    end

    expect(result).to be_a(Econt::Models::Shipments::CreateLabelResultElement)
    expect(result).not_to be_error
    expect(shipment_number).not_to be_nil
    expect(cleanup).to contain_exactly(be_a(Econt::Models::Shipments::DeleteLabelsResultElement))
    expect(cleanup.first).not_to be_error
    expect(verification).to all(be_a(Econt::Models::Shipments::ShipmentStatusResultElement))
    expect(label_cancelled?(verification)).to be(true)
  end

  def labels
    @labels ||= Econt::Services::Shipments::Label.new
  end

  def shipments
    @shipments ||= Econt::Services::Shipments::Shipment.new
  end

  def label_cancelled?(statuses)
    statuses.any? do |result|
      result.status&.tracking_events&.any? { |event| event.destination_type == 'canceled' }
    end
  end

  def synthetic_label
    {
      sender_client: { name: 'VCR Sender', phones: ['+359888000000'] },
      sender_address: sender_address,
      receiver_client: { name: 'VCR Receiver', phones: ['+359888000001'] },
      receiver_office_code: '1000',
      shipment_type: 'pack',
      pack_count: 1,
      weight: 1.0,
      shipment_description: 'econt-vcr-contract-fixture',
      services: {}
    }
  end

  def sender_address
    {
      city: { id: city_id, country: { code3: country_code } },
      street: 'бул. Витоша',
      num: '1'
    }
  end

  def city_id
    Integer(ENV.fetch('ECONT_CONTRACT_CITY_ID', '41'), 10)
  end

  def country_code
    ENV.fetch('ECONT_CONTRACT_COUNTRY_CODE', 'BGR')
  end
end
