# frozen_string_literal: true

RSpec.describe Econt do
  it 'has a version number' do
    expect(Econt::VERSION).not_to be nil
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
      Econt::Models::Shipments::UpdateLabelsResultElement
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
    service.grouping_cancelation(group_label: 789)
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
