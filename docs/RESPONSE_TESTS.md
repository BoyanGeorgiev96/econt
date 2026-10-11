# Offline response property contracts

The endpoint response specs exercise all 25 documented API endpoints through
the real client transport, request middleware and service result mapping, with
WebMock returning synthetic JSON. No carrier requests are made.

`spec/fixtures/examples/response_schemas.json` is a 2026-10-11 snapshot of the
schema and endpoint response definitions from
[the official OpenAPI document](https://ee.econt.com/services/openapi.yaml).
Descriptions are omitted; property names, types, formats and references are
retained. These are schema-derived examples, not recorded live responses.
Each endpoint has its own `responses/<endpoint>/success.json` and
`responses/<endpoint>/null_scalars.json` under `spec/fixtures/examples/`.
The checked-in payloads populate every optional documented field, nested object
and array with synthetic values independently of the gem's field declarations.
The error payload is shared in `responses/error.json`. Different scalar
values help detect accidental assignments between fields.
Every endpoint also receives a synthetic documented HTTP 400 error, with a
nested inner error and both populated and empty primitive arrays.

The recursive assertion in `spec/support/response_properties.rb` independently
derives snake_case reader names and compares each raw camelCase property with
the value obtained through `public_send`. It checks array sizes and each nested
element, including false, zero and nil. ISO dates and date-times are compared
against Date and DateTime values based on the documentation's format, not the
model's declared field types. Unsupported temporal representations, including
numeric epochs without an authoritative unit, retain their raw value.

Collection envelopes and single-resource wrappers are explicitly unwrapped
according to the public service return contract. Three-way logistics documents
an empty object, so its contract verifies an empty response model rather than
inventing properties. `set_itu_code` deliberately returns a Faraday response;
its empty raw body is compared directly. Raw hashes never count as evidence
that nested dot access works. Unknown response fields continue to be ignored,
as documented in PUBLIC_API.md, and have a separate compatibility regression.

`get_regions` is a helper derived from `get_cities`, not an additional API
endpoint. A manifest assertion requires every directly exposed service endpoint
to appear in the examples, so adding an endpoint requires a response contract.
The existing VCR specs remain complementary evidence of actual API behavior.

Run these offline contracts with:

```sh
bundle exec rspec spec/endpoint_response_properties_spec.rb spec/response_properties_spec.rb
```
