# Econt

A Ruby client for Econt's EEcont JSON API, with snake_case request keys,
typed responses, Basic authentication, and configurable timeouts.

Only JSON endpoints are supported; SOAP is not supported.

Community maintained; not affiliated with or endorsed by Econt.
See the [official API documentation](https://ee.econt.com/services/) for account
access and required fields.

## Installation

Requires Ruby 3.3 or later; CI tests Ruby 3.3, 3.4, and 4.0.

```bash
bundle add econt
```

## Configuration

```ruby
Econt::Client.configure do |config|
  config.username = ENV.fetch('ECONT_USERNAME')
  config.password = ENV.fetch('ECONT_PASSWORD')
  # Demo is the default. Use this URL for production:
  config.base_url = 'https://ee.econt.com/services/'
  config.open_timeout = 10
  config.read_timeout = 30
  config.write_timeout = 30
end
```

The default demo URL is `https://demo.econt.com/ee/services/`; production uses
`https://ee.econt.com/services/`, with separate credentials. Econt's documentation
lists HTTP example URLs but explicitly permits SSL connections with Basic
authentication. Authentication using client SSL certificates is not supported;
this is separate from HTTPS transport. Use HTTPS to protect credentials and
shipment data in transit, and keep requests server-side. TLS certificate
verification is enabled by default; TLS failures do not trigger an HTTP fallback.
An explicitly configured HTTP URL is still accepted but sends data without TLS.

### Rails initializer

```ruby
# config/initializers/econt.rb
Econt::Client.configure do |config|
  config.username = Rails.application.credentials.dig(:econt, :username)
  config.password = Rails.application.credentials.dig(:econt, :password)
  config.base_url = ENV.fetch('ECONT_BASE_URL', 'https://demo.econt.com/ee/services/')
end
```

Debug logging is opt-in with `config.debug = true` and
`config.debug_logger = Rails.logger`. Credentials are filtered; bodies are
excluded by default. `config.debug_bodies = true` can expose personal and
commercial data—use only for controlled local investigation.

## Usage

Requests use snake_case keys; responses expose snake_case readers and `to_h`.

```ruby
nomenclatures = Econt::Services::Nomenclatures::Nomenclatures.new
cities = nomenclatures.get_cities(country_code: 'BGR')
offices = nomenclatures.get_offices(country_code: 'BGR', city_id: cities.first.id)

addresses = Econt::Services::Nomenclatures::Address.new
result = addresses.validate_address(
  city: { country: { code3: 'BGR' }, name: 'София', post_code: '1000' },
  street: 'Витоша', num: '1'
)
result.validation_status
result.address
```

### Labels and tracking

```ruby
labels = Econt::Services::Shipments::Label.new
quote = labels.create_label(
  mode: 'calculate',
  label: {
    sender_client: { name: 'Sender', phones: ['+359888000000'] },
    sender_office_code: '1000',
    receiver_client: { name: 'Receiver', phones: ['+359888000001'] },
    receiver_office_code: '1000',
    shipment_type: 'pack', pack_count: 1, weight: 1.2,
    shipment_description: 'Artwork'
  }
)
quote.label.total_price
quote.label.currency

shipments = Econt::Services::Shipments::Shipment.new
statuses = shipments.get_shipment_statuses(shipment_numbers: ['1234567890123'])
statuses.first.status
```

Label modes include `calculate`, `validate`, `create`, and single-label
`calculate_with_block`. Creation and other mutations have real effects in the
selected environment. Example office codes and payloads must be adapted to your
account and shipment.

See the [Ruby API reference](docs/API.md) for every service method, its parameters,
return value, safety notes, and examples. The [endpoint matrix](docs/ENDPOINTS.md)
maps these methods to carrier operations; see the
[public API contract](docs/PUBLIC_API.md) for conversions and known limitations.

## Error handling

Transport and HTTP failures raise `Econt::Error`. Models and collections also
expose `error?` and `error` for carrier errors returned in a response.

Connection, timeout, and TLS failures use `Econt::ConnectionError`,
`Econt::TimeoutError`, and `Econt::SSLError`, under `Econt::TransportError`.
They have safe fixed messages; their original `cause` and `full_message` can
contain private data. There are no automatic retries, especially for mutations.

```ruby
begin
  result = labels.create_label(mode: 'validate', label: label_payload)
  Rails.logger.warn(result.error.full_message) if result.error?
rescue Econt::Error => error
  Rails.logger.warn("Econt request failed (status=#{error.status.inspect})")
  # Present an application-owned message; retry only when safe.
end
```

Review carrier error contents before logging or displaying them to customers.

## Versioning and support

We follow [Semantic Versioning](https://semver.org/). Before 1.0, minor releases
may change the public API incompatibly. From 1.0, incompatible changes to the
documented API require a major release.

There is no support SLA. Issues and PRs are reviewed best-effort, usually on
weekends. Fixes with tests are welcome; the MIT license permits maintaining a
fork. See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).

## Development

```bash
bin/setup
bundle exec rake
```

Offline tests cover request payloads and example-response mapping. See
[response tests](docs/RESPONSE_TESTS.md) for their scope and limitations.
Reviewed VCR recordings are replayed in CI with recording and network access
disabled; missing recordings are not fetched automatically.

To run the same credential-free replay locally:

```bash
ECONT_VCR_REPLAY=1 bundle exec rspec spec/recorded_contract_spec.rb
```

For deliberate demo recording, copy `.env.example` to `.env.test`, configure
credentials, and run:

```bash
ECONT_LIVE_TESTS=1 bundle exec rspec spec/live
```

The create/delete/status lifecycle requires `ECONT_MUTATING_LIVE_TESTS=1` as
well. Other unsafe mutations remain offline-tested. Review all recordings before
committing; see [VCR policy and cleanup paths](docs/VCR.md) and
[release instructions](docs/RELEASING.md).

## License

[MIT](LICENSE.txt).
