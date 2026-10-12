# Ruby API reference

This gem supports Econt's JSON endpoints only, not SOAP.

Every public service method is listed below. Configure `Econt::Client` first
(see the [README](../README.md#configuration)); constructing a service does not
send a request. Services share the configured client by default, or accept
`new(client: configured_client)` for a separately configured `Econt::Client`.

## Receivers and method index

| Receiver | Class | Methods |
| --- | --- | --- |
| `nomenclatures` | `Econt::Services::Nomenclatures::Nomenclatures` | [get_countries](#get_countries), [get_cities](#get_cities), [get_regions](#get_regions), [get_offices](#get_offices), [get_streets](#get_streets), [get_quarters](#get_quarters) |
| `addresses` | `Econt::Services::Nomenclatures::Address` | [validate_address](#validate_address), [address_service_times](#address_service_times), [get_nearest_offices](#get_nearest_offices) |
| `labels` | `Econt::Services::Shipments::Label` | [create_label](#create_label), [create_labels](#create_labels), [delete_labels](#delete_labels), [update_label](#update_label), [check_possible_shipment_editions](#check_possible_shipment_editions), [update_labels](#update_labels), [grouping](#grouping), [grouping_cancelation](#grouping_cancelation) |
| `shipments` | `Econt::Services::Shipments::Shipment` | [request_courier](#request_courier), [get_shipment_statuses](#get_shipment_statuses), [get_request_courier_status](#get_request_courier_status), [get_my_awb](#get_my_awb), [set_itu_code](#set_itu_code) |
| `profiles` | `Econt::Services::Profile::Profile` | [get_client_profiles](#get_client_profiles), [create_cd_agreement](#create_cd_agreement) |
| `reports` | `Econt::Services::PaymentReport::PaymentReport` | [payment_report](#payment_report) |
| `logistics` | `Econt::Services::ThreeWayLogistics::ThreeWayLogistics` | [three_way_logistics](#three_way_logistics) |

```ruby
nomenclatures = Econt::Services::Nomenclatures::Nomenclatures.new
addresses = Econt::Services::Nomenclatures::Address.new
labels = Econt::Services::Shipments::Label.new
shipments = Econt::Services::Shipments::Shipment.new
profiles = Econt::Services::Profile::Profile.new
reports = Econt::Services::PaymentReport::PaymentReport.new
logistics = Econt::Services::ThreeWayLogistics::ThreeWayLogistics.new
```

## How to use the reference

Signatures show Ruby defaults, not carrier requirements: an optional `nil`
or empty array does **not** mean the API accepts an incomplete request. Supply
the business fields required by the [official EEcont documentation](https://ee.econt.com/services/).
Nested hashes use snake_case except the legacy three-way logistics operation.

Examples are independent snippets, not a script to execute wholesale.
`address_payload`, `label_payload`, `updated_label_payload`,
`courier_payload`, `cd_pay_options_payload`, and `logistics_payload` are
application-owned hashes. Identifiers must belong to your account.
Dates and office/city IDs are illustrative; replace them before making requests.

Typed results expose snake_case readers and `to_h`. Collections are enumerable,
so use `each`, `first`, and `to_a`. Check `error?` on the result **and**
individual batch elements. HTTP failures raise `Econt::Error`. Connection,
timeout, and TLS failures raise `Econt::ConnectionError`, `Econt::TimeoutError`,
and `Econt::SSLError`, all subclasses of `Econt::TransportError < Econt::Error`.
Catch `Econt::Error` at your application's boundary. Parsing and programming
exceptions are not reclassified. The client never retries automatically; a
mutation timeout does not prove it failed.

```ruby
begin
  result = labels.create_label(label: label_payload, mode: 'validate')
  if result.error?
    # Handle result.error without exposing private carrier data.
  else
    result.label.to_h
  end
rescue Econt::Error => error
  # Record a safe diagnostic and decide whether reconciliation is needed.
end
```

Transport exception messages are fixed diagnostics without adapter details.
Their `cause` preserves the original Faraday exception; `cause`, backtraces,
and `full_message` may contain credentials, URLs, or personal data. Do not log
those blindly. Without an HTTP response, `status` and `error` are `nil`.

Mutations affect the selected environment. Read [cleanup limitations](VCR.md)
before using them. `calculate_with_block` reserves a label number; it is not
equivalent to a read-only quote. No example promises deletion or cancellation
will succeed after processing has started.

## Methods

### get_countries

`nomenclatures.get_countries`

List countries available for delivery.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Nomenclatures::Country>`.

No arguments.

```ruby
countries = nomenclatures.get_countries
```

### get_cities

`nomenclatures.get_cities(country_code:)`

List cities for a country.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Nomenclatures::City>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `country_code` | `String` | ISO country code, such as BGR. |

```ruby
cities = nomenclatures.get_cities(country_code: 'BGR')
```

### get_regions

`nomenclatures.get_regions(country_code:, language: nil)`

Fetch cities and derive unique, sorted region names; this is a local helper, not a separate endpoint.

Safety: **Read**. Returns `Array<String>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `country_code` | `String` | Country code. |
| `language` | `String, nil` | Only en selects English names; nil and other values select native names. |

This helper returns an ordinary array of names, not a model or collection. It
performs one `get_cities` request. HTTP/transport exceptions propagate, but an
embedded carrier error can yield an empty array. Use `get_cities` directly when
you need to distinguish that from a country with no regions.

```ruby
regions = nomenclatures.get_regions(country_code: 'BGR', language: 'en')
```

### get_offices

`nomenclatures.get_offices(country_code:, city_id: nil, show_cargo_receptions: nil, show_lc: nil, serving_receptions: nil)`

List offices with optional city and reception filters.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Nomenclatures::Office>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `country_code` | `String` | Country code. |
| `city_id` | `Integer, nil` | City identifier. |
| `show_cargo_receptions` | `Boolean, nil` | Include cargo receptions. |
| `show_lc` | `Boolean, nil` | Carrier LC filter. |
| `serving_receptions` | `Boolean, nil` | Carrier serving-reception filter. |

```ruby
offices = nomenclatures.get_offices(country_code: 'BGR', city_id: 41)
```

### get_streets

`nomenclatures.get_streets(city_id: nil)`

List streets, optionally restricted to a city.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Nomenclatures::Street>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `city_id` | `Integer, nil` | City identifier. |

```ruby
streets = nomenclatures.get_streets(city_id: 41)
```

### get_quarters

`nomenclatures.get_quarters(city_id: nil)`

List quarters, optionally restricted to a city.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Nomenclatures::Quarter>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `city_id` | `Integer, nil` | City identifier. |

```ruby
quarters = nomenclatures.get_quarters(city_id: 41)
```

### validate_address

`addresses.validate_address(address)`

Validate and normalize an address.

Safety: **Read**. Returns `Econt::Models::Nomenclatures::AddressValidationResponse`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `address` | `Hash, Econt::Models::Nomenclatures::Address` | Address fields; the argument is positional. |

```ruby
validation = addresses.validate_address(city: { id: 41 }, street: 'Витоша', num: '1')
```

### address_service_times

`addresses.address_service_times(city:, address:, date:, shipment_type:)`

Look up address service availability for a date and shipment type.

Safety: **Read**. Returns `Econt::Models::Nomenclatures::AddressServiceTimesResponse`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `city` | `Hash` | City fields. |
| `address` | `Hash` | Address fields. |
| `date` | `String` | Requested service date in the carrier format. |
| `shipment_type` | `String` | Carrier shipment type, such as pack. |

```ruby
times = addresses.address_service_times(
  city: { id: 41 }, address: address_payload,
  date: '2026-10-12', shipment_type: 'pack'
)
```

### get_nearest_offices

`addresses.get_nearest_offices(address:, shipment_type:)`

Find offices near an address for a shipment type.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Nomenclatures::Office>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `address` | `Hash` | Address fields. |
| `shipment_type` | `String` | Carrier shipment type. |

```ruby
offices = addresses.get_nearest_offices(address: address_payload, shipment_type: 'pack')
```

### create_label

`labels.create_label(label: nil, request_courier_time_from: nil, request_courier_time_to: nil, mode: nil)`

Calculate, validate, or create one shipping label.

Safety: **Conditional mutation**. Returns `Econt::Models::Shipments::CreateLabelResultElement`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `label` | `Hash, nil` | Shipping-label payload. |
| `request_courier_time_from` | `String, nil` | Requested courier window start. |
| `request_courier_time_to` | `String, nil` | Requested courier window end. |
| `mode` | `String, nil` | calculate or validate are non-mutating; create and calculate_with_block have effects. Always choose explicitly. |

The result contains `label` (a `ShippingLabel`), including prices and PDF URLs when supplied by the carrier. Use `mode: 'create'` only deliberately; `mode: 'calculate_with_block'` can reserve a number. Courier window arguments may request collection. PDF URLs are carrier-hosted; this method does not download them.

```ruby
quote = labels.create_label(label: label_payload, mode: 'calculate')
```

### create_labels

`labels.create_labels(labels: [], run_async_and_email_result_to: nil, mode: nil)`

Calculate, validate, or create a batch of labels.

Safety: **Conditional mutation**. Returns `Econt::Collection<Econt::Models::Shipments::CreateLabelResultElement>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `labels` | `Array<Hash>` | Shipping-label payloads. |
| `run_async_and_email_result_to` | `String, nil` | Email address for asynchronous results; the returned data may differ. |
| `mode` | `String, nil` | Choose calculate, validate, or create explicitly. |

Each item is a `CreateLabelResultElement`; inspect its `error?` before reading `label`. Use synchronous requests when you need the immediate batch result. Asynchronous email behavior is not independently contract-verified.

```ruby
quotes = labels.create_labels(labels: [label_payload], mode: 'calculate')
```

### delete_labels

`labels.delete_labels(shipment_numbers: [])`

Delete selected labels when allowed by carrier state and account permissions.

Safety: **Mutation**. Returns `Econt::Collection<Econt::Models::Shipments::DeleteLabelsResultElement>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `shipment_numbers` | `Array<String>` | Numbers of labels owned by your account. |

Inspect every `DeleteLabelsResultElement` and reconcile via `shipments.get_shipment_statuses`; a successful HTTP response alone does not prove every label was deleted.

```ruby
deleted = labels.delete_labels(shipment_numbers: [shipment_number])
```

### update_label

`labels.update_label(label: nil, request_courier_time_from: nil, request_courier_time_to: nil, destroy: nil, payment_addition_price: nil, payment_instruction: nil)`

Update or destroy an existing label.

Safety: **Mutation**. Returns `Econt::Models::Shipments::UpdateLabelResponse`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `label` | `Hash, nil` | Existing label with its shipment number and requested changes. |
| `request_courier_time_from` | `String, nil` | Courier window start. |
| `request_courier_time_to` | `String, nil` | Courier window end. |
| `destroy` | `Boolean, nil` | Whether to destroy the label. |
| `payment_addition_price` | `Hash, nil` | PaymentAdditionPrice fields. |
| `payment_instruction` | `Hash, nil` | PaymentInstruction fields. |

```ruby
updated = labels.update_label(label: updated_label_payload, destroy: false)
```

### check_possible_shipment_editions

`labels.check_possible_shipment_editions(shipment_nums: [])`

Check which edits are permitted for existing shipments.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Shipments::CheckPossibleShipmentEditionsResultElement>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `shipment_nums` | `Array<Integer>` | Shipment numbers in the carrier field type. |

```ruby
editions = labels.check_possible_shipment_editions(shipment_nums: [1234567890123])
```

### update_labels

`labels.update_labels(labels: [])`

Update several existing labels.

Safety: **Mutation**. Returns `Econt::Collection<Econt::Models::Shipments::UpdateLabelsResultElement>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `labels` | `Array<Hash>` | Existing labels and requested changes. |

Each item exposes optional `labels` (an `UpdateLabelResponse`) and `error`. The unusual plural reader matches the carrier contract.

```ruby
updated = labels.update_labels(labels: [updated_label_payload])
```

### grouping

`labels.grouping(labels: [])`

Group existing labels into a group label.

Safety: **Mutation**. Returns `Econt::Models::Shipments::ShipmentStatus`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `labels` | `Array<Integer>` | Shipment numbers to group. |

`labels` contains integer shipment numbers, not shipping-label hashes. Grouping cleanup is carrier-state dependent.

```ruby
group = labels.grouping(labels: [1234567890123, 1234567890124])
```

### grouping_cancelation

`labels.grouping_cancelation(group_label: nil)`

Cancel an existing group label.

Safety: **Mutation**. Returns `Econt::Models::Shipments::StatusResponse`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `group_label` | `Integer, nil` | Group-label shipment number. |

The Ruby spelling preserves the carrier operation `groupingCancelation`.

```ruby
result = labels.grouping_cancelation(group_label: group_label_number)
```

### request_courier

`shipments.request_courier(**attributes)`

Book a courier collection; pass the documented request fields as keywords.

Safety: **Mutation**. Returns `Econt::Models::Shipments::RequestCourierResponse`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `attributes` | `Hash` | Courier payload as keywords: request_time_from, request_time_to, shipment_type, shipment_pack_count, shipment_weight, sender_client, sender_agent, sender_address, attach_shipments, pack12, cargo_vehicle_options. |

```ruby
booking = shipments.request_courier(**courier_payload)
```

### get_shipment_statuses

`shipments.get_shipment_statuses(shipment_numbers: [])`

Read shipment status, tracking events, and label information.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Shipments::ShipmentStatusResultElement>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `shipment_numbers` | `Array<String>` | Shipment numbers to query. |

Each item exposes `status` (a `ShipmentStatus`) and an optional error. Read `statuses.first.status` only after checking both collection and item errors.

```ruby
statuses = shipments.get_shipment_statuses(shipment_numbers: [shipment_number])
```

### get_request_courier_status

`shipments.get_request_courier_status(request_courier_ids: [])`

Read the status of courier collection requests.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Shipments::RequestCourierStatusResultElement>`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `request_courier_ids` | `Array<Integer>` | Courier request identifiers. |

```ruby
statuses = shipments.get_request_courier_status(request_courier_ids: [courier_request_id])
```

### get_my_awb

`shipments.get_my_awb(date_from: nil, date_to: nil, page: nil, side: nil)`

List account waybills using optional date, page, and side filters.

Safety: **Read**. Returns `Econt::Models::Shipments::GetMyAwbResponse`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `date_from` | `String, nil` | Start date in carrier format. |
| `date_to` | `String, nil` | End date in carrier format. |
| `page` | `Integer, nil` | Requested page. |
| `side` | `String, nil` | Carrier side filter; see getMyAWB documentation for allowed values. |

```ruby
waybills = shipments.get_my_awb(date_from: '2026-10-01', date_to: '2026-10-12', page: 1)
```

### set_itu_code

`shipments.set_itu_code(awb_barcode:, truck_reg_num:, itu_code:)`

Assign ITU transport metadata to a waybill.

Safety: **Mutation**. Returns `Faraday::Response`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `awb_barcode` | `String` | Waybill barcode. |
| `truck_reg_num` | `String` | Truck registration number. |
| `itu_code` | `String` | ITU code; sent with the carrier spelling ITU_code. |

This operation returns the raw Faraday response, unlike typed endpoints. Inspect `response.body`; no `error?` reader is provided.

```ruby
response = shipments.set_itu_code(
  awb_barcode: shipment_number, truck_reg_num: truck_registration, itu_code: itu_code
)
response.body
```

### get_client_profiles

`profiles.get_client_profiles`

Read account client profiles and payment settings.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::Profile::ProfilesResponseElement>`.

No arguments.

Each item is a `ProfilesResponseElement`; account-specific profiles are nested in its documented readers.

```ruby
clients = profiles.get_client_profiles
```

### create_cd_agreement

`profiles.create_cd_agreement(cd_pay_options:)`

Create a cash-on-delivery payment agreement.

Safety: **Mutation**. Returns `Econt::Models::Profile::CDPayOptions`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `cd_pay_options` | `Hash` | CDPayOptions payload; account eligibility is carrier-controlled. |

```ruby
agreement = profiles.create_cd_agreement(cd_pay_options: cd_pay_options_payload)
```

### payment_report

`reports.payment_report(date_to: nil, date_from: nil)`

Read payment reports for an optional date range.

Safety: **Read**. Returns `Econt::Collection<Econt::Models::PaymentReport::PaymentReportRow>, Econt::Models::PaymentReport::PaymentReportRow`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `date_to` | `String, nil` | End date in carrier format. |
| `date_from` | `String, nil` | Start date in carrier format. |

The reviewed demo `PaymentReportRows` envelope returns a collection. The documented bare-row response returns one row; the example normalizes both to an array.

```ruby
rows = reports.payment_report(date_from: '2026-10-01', date_to: '2026-10-12')
rows = rows.is_a?(Econt::Collection) ? rows.to_a : [rows]
```

### three_way_logistics

`logistics.three_way_logistics(**attributes)`

Submit a three-way logistics request using legacy snake_case fields without camelCase conversion.

Safety: **Mutation**. Returns `Econt::Models::ThreeWayLogistics::ThreeWayLogisticsResponse`.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `attributes` | `Hash` | Legacy request fields as keywords; see ThreeWayLogisticsRequest for available field names. |

Request fields retain legacy snake_case on the wire. See `Econt::Models::ThreeWayLogistics::ThreeWayLogisticsRequest` for declared field names. The response contract has no authoritative successful fields, so the typed response currently has no data readers. Do not infer successful fulfillment from an empty model.

```ruby
result = logistics.three_way_logistics(**logistics_payload)
```

## Payload and model details

For nested request fields, consult the corresponding operation and model on the
[official service index](https://ee.econt.com/services/): `ShippingLabel`,
`Address`, `ClientProfile`, `CDPayOptions`, `PaymentInstruction`,
`PaymentAdditionPrice`, and `ThreeWayLogisticsRequest`.
The gem forwards supplied request fields; it does not perform full business validation.

Generate a searchable local method reference directly from
the source comments:

```bash
bundle install
bundle exec rake yard
open doc/index.html
```

Generated HTML lives in ignored `doc/`; Markdown lives in this repository and
is included in the gem. No GitHub wiki or hosted documentation is required.
YARD is a development dependency only. See [public API decisions](PUBLIC_API.md)
for coercion and response limitations, and [endpoint coverage](ENDPOINTS.md) for
the Ruby-to-carrier operation mapping.
