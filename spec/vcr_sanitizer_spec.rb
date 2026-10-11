# frozen_string_literal: true

RSpec.describe EcontVcrSanitizer do
  it 'redacts account response values while preserving JSON scalar types' do
    request = Struct.new(:uri).new('http://demo.test/Profile/ProfileService.getClientProfiles.json')
    response = Struct.new(:body).new(
      JSON.generate(
        clientID: 123,
        name: 'Real Name',
        phones: ['+359888123456'],
        address: { street: 'Private Street', num: '1' },
        pdfURL: 'https://example.test/label?_key=secret-token',
        active: true
      )
    )
    interaction = Struct.new(:request, :response).new(request, response)

    described_class.sanitize_response!(interaction)
    sanitized = JSON.parse(response.body)

    expect(sanitized).to include('clientID' => 0, 'name' => '<REDACTED>', 'active' => true)
    expect(sanitized.fetch('phones')).to eq(['<REDACTED>'])
    expect(sanitized.dig('address', 'street')).to eq('<REDACTED>')
    expect(sanitized.dig('address', 'num')).to eq('<REDACTED>')
    expect(sanitized.fetch('pdfURL')).to eq('<REDACTED>')
  end

  it 'uses one stable placeholder for a created label and its cleanup request' do
    create = interaction(
      uri: 'http://demo.test/Shipments/LabelService.createLabel.json',
      request_body: '{}',
      response_body: JSON.generate(
        label: { shipmentNumber: '1234567890123', senderClient: { name: 'Account Owner' } }
      )
    )
    delete = interaction(
      uri: 'http://demo.test/Shipments/LabelService.deleteLabels.json',
      request_body: JSON.generate(shipmentNumbers: ['1234567890123']),
      response_body: JSON.generate(results: [{ shipmentNum: '1234567890123' }])
    )

    described_class.sanitize_mutation!(create)
    described_class.sanitize_mutation!(delete)

    expect(create.response.body).to include('<ECONT_CREATED_SHIPMENT_NUMBER>')
    expect(create.response.body).not_to include('Account Owner')
    expect(delete.request.body).to include('<ECONT_CREATED_SHIPMENT_NUMBER>')
    expect(delete.response.body).to include('<ECONT_CREATED_SHIPMENT_NUMBER>')
  end

  def interaction(uri:, request_body:, response_body:)
    message = Struct.new(:body)
    request = Struct.new(:uri, :body).new(uri, request_body)
    Struct.new(:request, :response).new(request, message.new(response_body))
  end
end
