# Public API contract

This document records the compatibility decisions intended to remain stable
once the gem reaches version 1.0. The official EEcont documentation remains the
authority for required business fields and carrier behavior.

## Request and response conventions

- Only JSON endpoints are supported; SOAP is outside this gem's scope.
- Public service methods accept snake_case Ruby keywords and hashes. The
  middleware converts request keys to Econt's documented JSON casing.
- Responses are typed `Econt::Model` instances or `Econt::Collection` objects,
  as listed in the [Ruby API reference](API.md). Model readers use snake_case.
- Declared scalar fields are coerced to the documented primitive Ruby type.
  Dates and date-times become `Date` and `DateTime` when parsing succeeds.
- Missing optional fields return `nil`. Unknown response fields are ignored so
  an additive carrier response does not unexpectedly expand the gem's public
  model API. A new gem release can expose a documented field deliberately.
- `to_h` returns snake_case symbol keys. `to_json` converts keys back to Econt's
  request casing.
- `Econt::Collection` is enumerable and exposes `to_a`, `size`, `length`, and
  `count`; it is intentionally not an `Array` subclass.

Request parameters remain hashes because Econt's label and courier requests are
large, nested, and frequently revised. Responses are models because stable
readers, coercion, and nested types provide useful guarantees without forcing
callers to construct a very large request object graph.

## Errors

Transport failures and non-success HTTP statuses raise `Econt::Error`. Its
`status` contains the HTTP status when available, and `error` contains a typed
`Econt::Models::Error` when Econt returned one.

`Econt::TransportError < Econt::Error` is the common parent of
`ConnectionError`, `TimeoutError`, and `SSLError`. These wrap only Faraday's
connection, timeout, and TLS exceptions; parsing and programming errors retain
their original types. The original exception is preserved as `cause`, while
the wrapper message is a fixed safe diagnostic. No response means `status` and
`error` are `nil`. Causes, backtraces, and `full_message` may expose sensitive
adapter details, so scrub them before logging. No request is retried
automatically; reconcile mutations before deciding to retry.

Some Econt operations return an error object within an otherwise successful
response. Models and collections therefore expose `error?` and `error`. This is
kept separate from HTTP exceptions because it matches the carrier contract and
allows batch operations to contain both successful and failed elements.

## Documented response decisions

- `update_labels` returns a collection of `UpdateLabelsResultElement`. Econt
  explicitly documents each element as optional `error` plus optional `labels`,
  where `labels` is an `UpdateLabelResponse`. The unusual plural field name is
  retained instead of inventing a singular alias.
- `PreviousShipment#shipment_number` is an `Integer`, because Econt documents
  that particular field as `int`, even though most other shipment-number fields
  are strings. The inconsistency is intentionally represented rather than
  normalized.
- `payment_report` returns a collection of `PaymentReportRow` when the response
  contains `PaymentReportRows`, as seen in the reviewed demo recording. A null
  envelope produces an empty collection. The OpenAPI schema instead describes a
  bare row; that shape remains supported and returns one `PaymentReportRow`.
- `three_way_logistics` returns `ThreeWayLogisticsResponse`, currently an empty
  typed model. Econt documents request fields but no successful response fields.
  The gem does not invent undocumented readers.

Three-way logistics should be checked against demo responses before the 1.0 API
is frozen. If its actual response differs, correct the model during the pre-1.0
series and record the evidence in a scrubbed contract test.

## Compatibility policy

The gem follows [Semantic Versioning 2.0.0](https://semver.org/). During the
pre-1.0 series, minor versions may refine or correct the public contract as
real carrier responses are verified. These changes must still be documented.

After 1.0, removing or renaming public methods, changing accepted keywords, or
changing documented return types requires a new major version. Adding endpoint
methods, optional model readers, or new error subclasses is normally backward
compatible. Carrier-side behavior outside the gem's control is documented but
cannot be covered by semantic-version guarantees.
