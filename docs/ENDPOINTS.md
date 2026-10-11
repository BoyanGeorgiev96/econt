# Supported endpoints

All service operations use HTTP `POST`. Model names below omit the
`Econt::Models` namespace; collections are `Econt::Collection` instances.

| Area | Ruby method | Econt operation | Return value |
| --- | --- | --- | --- |
| Nomenclatures | `get_countries` | `getCountries` | collection of `Country` |
| Nomenclatures | `get_cities` | `getCities` | collection of `City` |
| Nomenclatures | `get_offices` | `getOffices` | collection of `Office` |
| Nomenclatures | `get_streets` | `getStreets` | collection of `Street` |
| Nomenclatures | `get_quarters` | `getQuarters` | collection of `Quarter` |
| Address | `validate_address` | `validateAddress` | `AddressValidationResponse` |
| Address | `address_service_times` | `addressServiceTimes` | `AddressServiceTimesResponse` |
| Address | `get_nearest_offices` | `getNearestOffices` | collection of `Office` |
| Labels | `create_label` | `createLabel` | `CreateLabelResultElement` |
| Labels | `create_labels` | `createLabels` | collection of results |
| Labels | `delete_labels` | `deleteLabels` | collection of results |
| Labels | `update_label` | `updateLabel` | `UpdateLabelResponse` |
| Labels | `check_possible_shipment_editions` | `checkPossibleShipmentEditions` | collection of results |
| Labels | `update_labels` | `updateLabels` | collection of results |
| Labels | `grouping` | `grouping` | `ShipmentStatus` |
| Labels | `grouping_cancelation` | `groupingCancelation` | `StatusResponse` |
| Shipments | `request_courier` | `requestCourier` | `RequestCourierResponse` |
| Shipments | `get_shipment_statuses` | `getShipmentStatuses` | collection of results |
| Shipments | `get_request_courier_status` | `getRequestCourierStatus` | collection of results |
| Shipments | `get_my_awb` | `getMyAWB` | `GetMyAwbResponse` |
| Shipments | `set_itu_code` | `setITUCode` | raw documented response |
| Profile | `get_client_profiles` | `getClientProfiles` | collection of profiles |
| Profile | `create_cd_agreement` | `createCDAgreement` | `CDPayOptions` |
| Payment reports | `payment_report` | `PaymentReport` | collection of `PaymentReportRow`; bare row also supported |
| Three-way logistics | `three_way_logistics` | `threeWayLogistics` | empty typed response |

`get_regions(country_code:, language: nil)` is a local helper, not an Econt
endpoint. It calls `get_cities` and returns unique, sorted region names (English
when `language: 'en'`).

The spelling of `PaymentReport`, `getMyAWB`, `groupingCancelation`, and
`setITUCode` follows Econt's published operation names. Every listed operation
has offline example-response coverage; that is not equivalent to live contract
verification. See [response tests](RESPONSE_TESTS.md), [VCR coverage](VCR.md), and
[public API limitations](PUBLIC_API.md).
