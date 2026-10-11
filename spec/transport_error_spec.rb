# frozen_string_literal: true

RSpec.describe Econt::TransportError do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:client) { instance_double(Econt::Client, connection: connection) }
  let(:service) { Econt::Services::Shipments::Label.new(client: client) }

  operations = {
    get: [:get, { params: { page: 1 } }],
    post: [:post, { body: { label: {} } }],
    post_raw: [:post, { body: { label: {} } }],
    patch: [:patch, { body: { label: {} } }],
    put: [:put, { body: { label: {} } }],
    delete: [:delete, { params: { id: 1 } }]
  }.freeze

  failures = {
    Faraday::ConnectionFailed => [Econt::ConnectionError, 'Econt API connection failed.'],
    Faraday::TimeoutError => [Econt::TimeoutError, 'Econt API request timed out.'],
    Faraday::SSLError => [Econt::SSLError, 'Econt API TLS connection failed.']
  }.freeze

  operations.each do |operation, (verb, options)|
    failures.each do |failure, (wrapper, safe_message)|
      it "wraps #{failure} from #{operation} without exposing or retrying it" do
        original = failure.new('private-password https://account:secret@example.invalid/customer')
        expect(connection).to receive(verb).once.and_raise(original)

        expect { service.send(operation, 'synthetic', **options) }.to raise_error(wrapper) do |error|
          expect(error).to be_a(Econt::Error)
          expect(error).to be_a(Econt::TransportError)
          expect(error.message).to eq(safe_message)
          expect(error.message).not_to include('private-password', 'secret', 'customer')
          expect(error.cause).to equal(original)
          expect(error.status).to be_nil
          expect(error.error).to be_nil
        end
      end
    end
  end

  [Faraday::ParsingError, Faraday::Error, ArgumentError, NoMethodError].each do |failure|
    it "does not reclassify #{failure}" do
      original = failure.new('original diagnostic')
      expect(connection).to receive(:post).once.and_raise(original)
      expect { service.create_label(label: {}, mode: 'create') }.to raise_error do |error|
        expect(error).to equal(original)
      end
    end
  end

  it 'wraps a public mutation without retrying it' do
    original = Faraday::TimeoutError.new('private adapter diagnostic')
    expect(connection).to receive(:post).with(
      'Shipments/LabelService.createLabel.json', anything, anything
    ).once.and_raise(original)

    expect { service.create_label(label: {}, mode: 'create') }.to raise_error(Econt::TimeoutError) do |error|
      expect(error.cause).to equal(original)
    end
  end

  it 'preserves ordinary HTTP errors and their status' do
    response = instance_double(Faraday::Response, body: {}, status: 401)
    expect(connection).to receive(:post).once.and_return(response)

    expect { service.create_label(label: {}, mode: 'create') }.to raise_error(Econt::Error) do |error|
      expect(error).not_to be_a(Econt::TransportError)
      expect(error.status).to eq(401)
    end
  end

  it 'preserves a programming failure during serialization' do
    unserializable = Object.new
    def unserializable.to_json(*)
      raise ArgumentError, 'broken JSON serializer'
    end

    expect(connection).not_to receive(:post)
    expect do
      service.send(:post_raw, 'synthetic', body: { value: unserializable })
    end.to raise_error(ArgumentError, 'broken JSON serializer')
  end

  it 'does not wrap exceptions raised while handling an existing response' do
    response = instance_double(Faraday::Response, body: {}, status: 200)
    original = Faraday::ConnectionFailed.new('non-transport response handler failure')
    expect(connection).to receive(:post).once.and_return(response)
    expect(service).to receive(:response_for).with(response).and_raise(original)

    expect { service.create_label(label: {}, mode: 'create') }.to raise_error do |error|
      expect(error).to equal(original)
    end
  end
end
