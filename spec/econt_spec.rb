# frozen_string_literal: true

RSpec.describe Econt do
  it 'has a version number' do
    expect(Econt::VERSION).not_to be nil
  end

  it 'uses Econt\'s HTTP demo endpoint by default' do
    expect(Econt::Client.new.base_url).to eq('http://demo.econt.com/ee/services/')
  end

  it 'configures bounded network timeouts' do
    client = Econt::Client.new
    client.username = 'user'
    client.password = 'pass'
    client.open_timeout = 4
    client.read_timeout = 5
    client.write_timeout = 6
    client.setup_connection!

    expect(client.connection.options).to have_attributes(
      open_timeout: 4,
      timeout: 5,
      write_timeout: 6
    )
  end

  it 'sends an empty JSON object for parameterless POST operations' do
    client = Econt::Client.new
    client.username = 'user'
    client.password = 'pass'
    client.setup_connection!

    request = stub_request(
      :post,
      'http://demo.econt.com/ee/services/Nomenclatures/NomenclaturesService.getCountries.json'
    ).with(
      body: '{}',
      headers: { 'Content-Type' => 'application/json' }
    ).to_return(
      status: 200,
      body: '{"countries":[]}',
      headers: { 'Content-Type' => 'application/json' }
    )

    countries = Econt::Services::Nomenclatures::Nomenclatures.new(client: client).get_countries

    expect(request).to have_been_requested.once
    expect(countries).to be_empty
  end

  it 'maps address validation response details' do
    response = Econt::Models::Nomenclatures::AddressValidationResponse.new(
      'address' => {
        'city' => { 'name' => 'София' },
        'street' => 'Витоша',
        'num' => '1'
      },
      'validationStatus' => 'Normal',
      'serviceInfo' => {
        'allowedPacksCourierRequest' => true,
        'deliveryPacksExtraDelayDays' => 1,
        'allowedCargoCourierRequest' => false,
        'deliveryCargoExtraDelayDays' => 2,
        'allowedPalletCourierRequest' => true,
        'deliveryPalletExtraDelayDays' => 3
      }
    )

    expect(response.address).to be_a(Econt::Models::Nomenclatures::Address)
    expect(response.validation_status).to eq('Normal')
    expect(response.service_info).to be_a(Econt::Models::Nomenclatures::AddressServiceInfo)
    expect(response.service_info.allowed_packs_courier_request).to be(true)
    expect(response.service_info.delivery_pallet_extra_delay_days).to eq(3)
  end

  it 'posts address validation payloads as nested objects, not JSON strings' do
    service = Econt::Services::Nomenclatures::Address.allocate
    response = Struct.new(:body).new({})

    expect(service).to receive(:post).with(
      'validateAddress',
      body: {
        address: {
          city: {
            country: { code2: 'BG' },
            name: 'Русе'
          },
          street: 'Славянска',
          num: '16'
        }
      }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::Nomenclatures::AddressValidationResponse
    )

    service.validate_address(
      city: {
        country: { code2: 'BG' },
        name: 'Русе'
      },
      street: 'Славянска',
      num: '16'
    )
  end

  it 'posts label service payloads' do
    service = Econt::Services::Shipments::Label.allocate
    response = Struct.new(:body).new({})

    expect(service).to receive(:post).with(
      'createLabel',
      body: {
        label: { shipment_type: 'PACK' },
        request_courier_time_from: '10:00',
        request_courier_time_to: '12:00',
        mode: 'create'
      }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::Shipments::CreateLabelResultElement
    )
    service.create_label(
      label: { shipment_type: 'PACK' },
      request_courier_time_from: '10:00',
      request_courier_time_to: '12:00',
      mode: 'create'
    )

    expect(service).to receive(:post).with(
      'createLabels',
      body: {
        labels: [{ shipment_type: 'PACK' }],
        run_async_and_email_result_to: 'ops@example.test',
        mode: 'validate'
      }
    ).and_return(response)
    expect(service).to receive(:collection).with(
      response,
      Econt::Models::Shipments::CreateLabelResultElement
    )
    service.create_labels(
      labels: [{ shipment_type: 'PACK' }],
      run_async_and_email_result_to: 'ops@example.test',
      mode: 'validate'
    )

    expect(service).to receive(:post).with(
      'updateLabel',
      body: {
        label: { shipment_number: '123' },
        request_courier_time_from: '13:00',
        request_courier_time_to: '15:00',
        destroy: false,
        payment_addition_price: { amount: 1.23 },
        payment_instruction: { method: 'cash' }
      }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::Shipments::UpdateLabelResponse
    )
    service.update_label(
      label: { shipment_number: '123' },
      request_courier_time_from: '13:00',
      request_courier_time_to: '15:00',
      destroy: false,
      payment_addition_price: { amount: 1.23 },
      payment_instruction: { method: 'cash' }
    )
  end

  it 'posts label collection and grouping payloads' do
    service = Econt::Services::Shipments::Label.allocate
    response = Struct.new(:body).new({})

    expect(service).to receive(:post).with(
      'deleteLabels',
      body: { shipment_numbers: %w[123 456] }
    ).and_return(response)
    expect(service).to receive(:collection).with(
      response,
      Econt::Models::Shipments::DeleteLabelsResultElement
    )
    service.delete_labels(shipment_numbers: %w[123 456])

    expect(service).to receive(:post).with(
      'checkPossibleShipmentEditions',
      body: { shipment_nums: [123, 456] }
    ).and_return(response)
    expect(service).to receive(:collection).with(
      response,
      Econt::Models::Shipments::CheckPossibleShipmentEditionsResultElement
    )
    service.check_possible_shipment_editions(shipment_nums: [123, 456])

    expect(service).to receive(:post).with(
      'updateLabels',
      body: { labels: [{ label: { shipment_number: '123' } }] }
    ).and_return(response)
    expect(service).to receive(:collection).with(
      response,
      Econt::Models::Shipments::UpdateLabelsResultElement
    )
    service.update_labels(labels: [{ label: { shipment_number: '123' } }])

    expect(service).to receive(:post).with(
      'grouping',
      body: { labels: [123, 456] }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::Shipments::ShipmentStatus,
      key: :label
    )
    service.grouping(labels: [123, 456])

    expect(service).to receive(:post).with(
      'groupingCancelation',
      body: { group_label: 789 }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::Shipments::StatusResponse
    )
    service.grouping_cancelation(group_label: 789)
  end

  it 'posts documented shipment service payloads' do
    service = Econt::Services::Shipments::Shipment.allocate
    response = Struct.new(:body).new({})

    expect(service).to receive(:post).with(
      'requestCourier',
      body: {
        request_time_from: 1_767_255_600,
        request_time_to: 1_767_262_800,
        shipment_type: 'pack',
        shipment_pack_count: 2,
        shipment_weight: 3.5,
        attach_shipments: %w[123 456]
      }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::Shipments::RequestCourierResponse
    )
    service.request_courier(
      request_time_from: 1_767_255_600,
      request_time_to: 1_767_262_800,
      shipment_type: 'pack',
      shipment_pack_count: 2,
      shipment_weight: 3.5,
      attach_shipments: %w[123 456]
    )

    expect(service).to receive(:post).with(
      'getShipmentStatuses',
      body: { shipment_numbers: %w[123 456] }
    ).and_return(response)
    expect(service).to receive(:collection).with(
      response,
      Econt::Models::Shipments::ShipmentStatusResultElement
    )
    service.get_shipment_statuses(shipment_numbers: %w[123 456])

    expect(service).to receive(:post).with(
      'getRequestCourierStatus',
      body: { request_courier_ids: %w[10 11] }
    ).and_return(response)
    expect(service).to receive(:collection).with(
      response,
      Econt::Models::Shipments::RequestCourierStatusResultElement
    )
    service.get_request_courier_status(request_courier_ids: %w[10 11])

    expect(service).to receive(:post).with(
      'getMyAWB',
      body: { date_from: '2026-01-01', date_to: '2026-01-31', page: 2, side: 'sender' }
    ).and_return(response)
    expect(service).to receive(:resource).with(
      response,
      Econt::Models::Shipments::GetMyAwbResponse
    )
    service.get_my_awb(date_from: '2026-01-01', date_to: '2026-01-31', page: 2, side: 'sender')
  end

  it 'maps structured service-time and AWB responses' do
    service_times = Econt::Models::Nomenclatures::AddressServiceTimesResponse.new(
      'serviceOffice' => { 'code' => '1000' },
      'serviceOfficeLatitude' => 42.6977,
      'serviceOfficeClientsWorkTimes' => [{ 'start' => '09:00', 'end' => '18:00' }],
      'serviceOfficeNext30daysWorkTime' => [{ 'dayType' => 'workday', 'day' => '2026-01-02' }]
    )
    awb = Econt::Models::Shipments::GetMyAwbResponse.new(
      'dateFrom' => '2026-01-01',
      'dateTo' => '2026-01-31',
      'page' => 1,
      'totalPages' => 2,
      'results' => [{ 'shipmentNumber' => '123' }]
    )

    expect(service_times.service_office).to be_a(Econt::Models::Nomenclatures::Office)
    expect(service_times.service_office_clients_work_times.first)
      .to be_a(Econt::Models::Nomenclatures::WorkingTime)
    expect(service_times.service_office_next30days_work_time.first)
      .to be_a(Econt::Models::Nomenclatures::WorkingDateTime)
    expect(awb.total_pages).to eq(2)
    expect(awb.results.first).to be_a(Econt::Models::Shipments::GetMyAwbResultElement)
  end

  it 'extracts collections from camelCase API response keys' do
    statuses = Econt::Models::Shipments::ShipmentStatusResultElement.collection(
      'shipmentStatuses' => [{ 'status' => { 'shipmentNumber' => '123' } }]
    )

    expect(statuses.size).to eq(1)
    expect(statuses.first.status.shipment_number).to eq('123')
  end

  it 'maps documented array fields and preserves missing optional values' do
    label = Econt::Models::Shipments::ShippingLabel.new(
      'senderClient' => { 'phones' => ['+359888123456'] },
      'packs' => [{ 'width' => 10 }],
      'instructions' => [{ 'attachments' => [{ 'filename' => 'note.pdf' }] }],
      'customsList' => [{ 'cn' => '97011000', 'sum' => 42.5, 'currency' => 'EUR' }]
    )

    expect(label.sender_client.phones).to eq(['+359888123456'])
    expect(label.packs.first).to be_a(Econt::Models::Shipments::PackElement)
    expect(label.instructions.first.attachments.first).to be_a(Econt::Models::HostedFile)
    expect(label.customs_list.first.cn).to eq('97011000')
    expect(label.pack_count).to be_nil
  end

  it 'uses official acronym casing in outgoing payloads' do
    middleware = Econt::CamelCaseMiddleware.new(->(env) { env })

    expect(middleware.send(:to_camel_case, :city_id)).to eq('cityID')
    expect(middleware.send(:to_camel_case, :is_eu)).to eq('isEU')
    expect(middleware.send(:to_camel_case, :receiver_iban)).to eq('receiverIBAN')
    expect(middleware.send(:to_camel_case, :pdf_url)).to eq('pdfURL')
  end

  it 'exposes services under their documented namespaces' do
    expect(Econt::Services::Profile::Profile.name).to eq('Econt::Services::Profile::Profile')
    expect(Econt::Services::PaymentReport::PaymentReport.name)
      .to eq('Econt::Services::PaymentReport::PaymentReport')
    expect(Econt::Services::ThreeWayLogistics::ThreeWayLogistics.name)
      .to eq('Econt::Services::ThreeWayLogistics::ThreeWayLogistics')
  end

  it 'preserves documented legacy keys for ITU and three-way-logistics requests' do
    shipment_service = Econt::Services::Shipments::Shipment.allocate
    logistics_service = Econt::Services::ThreeWayLogistics::ThreeWayLogistics.allocate
    response = Struct.new(:body).new({})

    expect(shipment_service).to receive(:post_raw).with(
      'setITUCode',
      body: {
        'awbBarcode' => '123',
        'truckRegNum' => 'CA1234AB',
        'ITU_code' => 'ITU-1'
      }
    ).and_return(response)
    shipment_service.set_itu_code(awb_barcode: '123', truck_reg_num: 'CA1234AB', itu_code: 'ITU-1')

    expect(logistics_service).to receive(:post_raw).with(
      'threeWayLogistics',
      body: { 'requester_name' => 'Example Ltd', 'supplier_city' => 'Sofia' }
    ).and_return(response)
    expect(logistics_service).to receive(:resource).with(
      response,
      Econt::Models::ThreeWayLogistics::ThreeWayLogisticsResponse
    )
    logistics_service.three_way_logistics(requester_name: 'Example Ltd', supplier_city: 'Sofia')
  end

  it 'uses documented profile and payment report response shapes' do
    profile_service = Econt::Services::Profile::Profile.allocate
    payment_service = Econt::Services::PaymentReport::PaymentReport.allocate
    response = Struct.new(:body).new({})

    expect(profile_service).to receive(:post).with(
      'createCDAgreement',
      body: { cd_pay_options: { method: 'bank' } }
    ).and_return(response)
    expect(profile_service).to receive(:resource).with(
      response,
      Econt::Models::Profile::CDPayOptions,
      key: :cd_pay_options
    )
    profile_service.create_cd_agreement(cd_pay_options: { method: 'bank' })

    expect(payment_service).to receive(:post).with(
      'PaymentReport',
      body: { date_to: '2026-01-31', date_from: '2026-01-01' }
    ).and_return(response)
    expect(payment_service).to receive(:resource).with(
      response,
      Econt::Models::PaymentReport::PaymentReportRow
    )
    payment_service.payment_report(date_from: '2026-01-01', date_to: '2026-01-31')
  end

  it 'keeps debug bodies off and redacts credentials by default' do
    output = StringIO.new
    client = Econt::Client.new
    client.username = 'debug-user'
    client.password = 'debug-password'
    client.debug = true
    client.debug_logger = Logger.new(output)
    client.setup_connection!

    stub_request(:post, 'http://demo.econt.com/ee/services/debug')
      .to_return(status: 200, body: '{"customer":"private-name"}', headers: { 'Content-Type' => 'application/json' })

    client.connection.post('debug', customer: 'private-name')

    expect(output.string).to include('<ECONT_BASIC_TOKEN>')
    expect(output.string).not_to include('debug-user', 'debug-password', 'private-name')
  end

  it 'logs bodies only after an explicit opt-in while still redacting credentials' do
    output = StringIO.new
    client = Econt::Client.new
    client.username = 'debug-user'
    client.password = 'debug-password'
    client.debug = true
    client.debug_bodies = true
    client.debug_logger = Logger.new(output)
    client.setup_connection!

    stub_request(:post, 'http://demo.econt.com/ee/services/debug')
      .to_return(status: 200, body: '{"customer":"private-name"}', headers: { 'Content-Type' => 'application/json' })

    client.connection.post('debug', customer: 'private-name')

    expect(output.string).to include('private-name')
    expect(output.string).not_to include('debug-user', 'debug-password')
  end

  it 'builds nested Econt error models' do
    error = Econt::Models::Error.new(
      'type' => 'ExInvalidParam',
      'message' => '',
      'fields' => [],
      'innerErrors' => [
        {
          'type' => 'ExInvalidCity',
          'message' => 'Невалиднo населено място.',
          'fields' => [],
          'innerErrors' => []
        }
      ]
    )

    expect(error.type).to eq('ExInvalidParam')
    expect(error.inner_errors.size).to eq(1)
    expect(error.inner_errors.first.type).to eq('ExInvalidCity')
    expect(error.full_message).to eq('Невалиднo населено място.')
  end

  it 'builds an error on response models when the response body is an Econt error' do
    response = Econt::Models::Nomenclatures::AddressValidationResponse.new(
      'type' => 'ExInvalidParam',
      'message' => '',
      'fields' => [],
      'innerErrors' => [
        {
          'type' => 'ExInvalidCity',
          'message' => 'Невалиднo населено място.',
          'fields' => [],
          'innerErrors' => []
        }
      ]
    )

    expect(response).to be_error
    expect(response.validation_status).to eq('invalid')
    expect(response.error).to be_a(Econt::Models::Error)
    expect(response.error.inner_errors.size).to eq(1)
    expect(response.error.inner_errors.first.type).to eq('ExInvalidCity')
  end

  it 'does not raise in response_for when the response body is an Econt error' do
    service = Class.new(Econt::ServiceResource) do
      def service_url
        'Test'
      end
    end.allocate
    response = Struct.new(:status, :body).new(
      200,
      {
        'type' => 'ExInvalidParam',
        'message' => '',
        'fields' => [],
        'innerErrors' => [
          {
            'type' => 'ExInvalidCity',
            'message' => 'Невалиднo населено място.',
            'fields' => [],
            'innerErrors' => []
          }
        ]
      }
    )

    expect(service.send(:response_for, response)).to eq(response)
  end

  it 'does not treat ordinary typed response bodies as Econt errors' do
    service = Class.new(Econt::ServiceResource) do
      def service_url
        'Test'
      end
    end.allocate
    response = Struct.new(:status, :body).new(200, { 'type' => 'shipment' })

    expect(service.send(:response_for, response)).to eq(response)
  end

  it 'raises Econt::Error for undocumented non-success statuses' do
    service = Class.new(Econt::ServiceResource) do
      def service_url
        'Test'
      end
    end.allocate
    response = Struct.new(:status, :body).new(517, {})

    expect { service.send(:response_for, response) }
      .to raise_error(Econt::Error) { |error|
        expect(error.status).to eq(517)
        expect(error.error).to be_nil
        expect(error.message).to eq('Econt API request failed with status 517.')
      }
  end

  it 'raises Econt::Error for server errors when the body can be built as an Econt error' do
    service = Class.new(Econt::ServiceResource) do
      def service_url
        'Test'
      end
    end.allocate
    response = Struct.new(:status, :body).new(
      517,
      {
        'type' => 'ExInvalidParam',
        'message' => '',
        'fields' => [],
        'innerErrors' => [
          {
            'type' => 'ExInvalidCity',
            'message' => 'Невалиднo населено място.',
            'fields' => [],
            'innerErrors' => []
          }
        ]
      }
    )

    expect { service.send(:response_for, response) }
      .to raise_error(Econt::Error) { |error|
        expect(error.status).to eq(517)
        expect(error.error).to be_a(Econt::Models::Error)
        expect(error.error.inner_errors.first.type).to eq('ExInvalidCity')
      }
  end

  it 'uses the status fallback when an Econt error body has no message' do
    error = Econt::Models::Error.new(
      'type' => 'ExInvalidParam',
      'message' => '',
      'fields' => [],
      'innerErrors' => []
    )

    exception = Econt::Error.new(error: error, status: 517)

    expect(exception.message).to eq('Econt API request failed with status 517.')
  end
end
