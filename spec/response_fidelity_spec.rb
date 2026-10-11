# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'documented response fidelity' do
  it 'maps a single-label update response through UpdateLabelResponse' do
    service = Econt::Services::Shipments::Label.allocate
    response = Struct.new(:body).new({ 'label' => { 'shipmentNumber' => '123' } })

    expect(service).to receive(:post).with(
      'updateLabel',
      body: {
        label: { shipment_number: '123' },
        request_courier_time_from: nil,
        request_courier_time_to: nil,
        destroy: nil,
        payment_addition_price: nil,
        payment_instruction: nil
      }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::Shipments::UpdateLabelResponse
    ).and_call_original

    result = service.update_label(label: { shipment_number: '123' })

    expect(result.label).to be_a(Econt::Models::Shipments::ShipmentStatus)
    expect(result.label.shipment_number).to eq('123')
  end

  it 'maps the documented nested updateLabels success structure' do
    result = Econt::Models::Shipments::UpdateLabelsResultElement.new(
      'labels' => { 'label' => { 'shipmentNumber' => '123' } }
    )

    expect(result.labels).to be_a(Econt::Models::Shipments::UpdateLabelResponse)
    expect(result.labels.label).to be_a(Econt::Models::Shipments::ShipmentStatus)
    expect(result.labels.label.shipment_number).to eq('123')
  end

  it 'returns the documented empty three-way-logistics response model' do
    service = Econt::Services::ThreeWayLogistics::ThreeWayLogistics.allocate
    response = Struct.new(:body).new({})

    expect(service).to receive(:post_raw).with(
      'threeWayLogistics',
      body: { 'requester_name' => 'Example Ltd', 'supplier_city' => 'Sofia' }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::ThreeWayLogistics::ThreeWayLogisticsResponse
    ).and_call_original

    result = service.three_way_logistics(requester_name: 'Example Ltd', supplier_city: 'Sofia')

    expect(result).to be_a(Econt::Models::ThreeWayLogistics::ThreeWayLogisticsResponse)
    expect(result.to_h).to eq({})
  end

  it 'keeps the legacy three-way request field names explicit' do
    request = Econt::Models::ThreeWayLogistics::ThreeWayLogisticsRequest.new(
      'requester_name' => 'Example Ltd',
      'supplier_city' => 'Sofia'
    )

    expect(request.to_h).to eq(requester_name: 'Example Ltd', supplier_city: 'Sofia')
  end

  it 'uses the documented scalar types for AWB dates and SMS notification' do
    awb = Econt::Models::Shipments::GetMyAwbResultElement.new(
      'createdDate' => '2026-01-02T10:30:45+02:00',
      'acceptedDate' => '2026-01-03T11:45:30+02:00'
    )
    label = Econt::Models::Shipments::ShippingLabel.new('smsOnDelivery' => '1')

    expect(awb.created_date).to be_a(DateTime)
    expect(awb.created_date.hour).to eq(10)
    expect(awb.accepted_date).to be_a(DateTime)
    expect(awb.accepted_date.minute).to eq(45)
    expect(label.sms_on_delivery).to eq('1')
  end

  it 'uses Econt\'s documented integer type for previous shipment numbers' do
    previous = Econt::Models::Shipments::PreviousShipment.new('shipmentNumber' => '123')

    expect(previous.shipment_number).to eq(123)
  end

  it 'maps the OpenAPI payment-report response as one row' do
    service = Econt::Services::PaymentReport::PaymentReport.allocate
    response = Struct.new(:body).new({ 'num' => 123, 'amount' => 42.5, 'currency' => 'EUR' })

    expect(service).to receive(:post).and_return(response)
    result = service.payment_report(date_from: '2026-01-01', date_to: '2026-01-31')

    expect(result).to be_a(Econt::Models::PaymentReport::PaymentReportRow)
    expect(result.num).to eq(123)
    expect(result.amount).to eq(42.5)
  end

  it 'coerces documented primitive array element types' do
    options = Econt::Models::Profile::CDPayOptions.new(
      'payDays' => ['5'],
      'payWeekdays' => [:monday]
    )
    client = Econt::Models::Profile::ClientProfile.new('phones' => [359_888_123_456])
    error = Econt::Models::Error.new('fields' => [:city])

    expect(options.pay_days).to eq([5])
    expect(options.pay_weekdays).to eq(['monday'])
    expect(client.phones).to eq(['359888123456'])
    expect(error.fields).to eq(['city'])
  end
end
