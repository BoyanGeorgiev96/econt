# VCR contract testing

The opt-in contract suite records real demo responses. Normal tests never
contact Econt. CI replays every reviewed cassette through the public service
methods, without loading `.env` files or needing credentials:

```bash
ECONT_VCR_REPLAY=1 bundle exec rspec spec/recorded_contract_spec.rb
```

Replay uses VCR `record: :none` and a request firewall: missing or unmatched
interactions fail instead of contacting Econt, even if recording options are
overridden. WebMock also disables network connections. The replay spec is
separate from the opt-in recording suite, so account-specific recording settings
cannot silently skip CI coverage.

Existing reviewed cassettes were recorded over HTTP. Replay explicitly uses
that historical base URL with all network access blocked; the recordings are
not relabeled as HTTPS evidence. New demo recordings default to HTTPS.

Each endpoint has an independent cassette so a failed recording can be removed
and retried without discarding unrelated evidence.

The historical client-profile recording had whole address objects replaced with
strings by an earlier scrubber. Those slots are now empty objects, preserving
their counts and valid model shape; their nested address properties are not
live-verified by this cassette. New recordings retain nested structure and redact
only sensitive scalar values. Replay compares every present documented field,
not optional absent fields or undocumented fields intentionally ignored by models.

## Read-only coverage

The suite covers nomenclatures, address validation and service lookup, client
profiles, label calculation and validation modes, payment reports, AWB history,
and optional shipment/courier-status reads. Account-specific identifiers are
supplied through `.env` and their recordings are structurally sanitized.

Offline request-shape specs exercise every explicit public keyword at least
once. Large nested label and logistics hashes use generic serialization, so
representative documented fields and model casting are tested without trying
every possible field combination. Live contracts use the smallest meaningful
payload for each server behavior; they are not a parameter-permutation suite.

## Coverage policy

| Endpoint kind | Contract approach |
| --- | --- |
| Nomenclatures and address queries | Recorded directly, one cassette per endpoint |
| Profiles, reports, AWB, shipment, and courier-status reads | Recorded with dedicated demo fixtures and structural response redaction |
| Single label `validate`/`calculate` and bulk label `validate` modes | Recorded because these modes do not create shipments |
| Label creation/update/deletion/grouping, courier requests, ITU, CDA, and three-way logistics | Excluded from the read-only suite; use the lifecycle pattern below |

## Mutating endpoints

VCR does not make a mutating operation safe: the first recording is still a
real request. Projects that contract-test creation or updates normally use a
dedicated demo account and record a complete scenario in one cassette:

1. create a uniquely identifiable fixture;
2. exercise the update or action being tested;
3. query the result;
4. delete or cancel the fixture in an `ensure` cleanup block; and
5. confirm the cleanup response before accepting the cassette.

Recording is a manual maintenance operation, never a normal CI action. CI only
replays reviewed cassettes with network access disabled. Identifiers,
credentials, names, phones, addresses, payment data, cookies, and tokens must
be scrubbed while preserving the JSON scalar types expected by model casting.
If an API offers no reliable cleanup, prefer a provider sandbox reset, a
pre-provisioned disposable fixture, or an offline request-shape test instead of
recording the mutation.

Never re-record all cassettes automatically. Delete only the cassette being
refreshed, inspect the diff, verify cleanup through a status request, and scan the
result for secrets and personal data before committing it.

## Reviewed mutation example

`spec/live/label_mutation_contract_spec.rb` implements the lifecycle above for
label creation. It creates a synthetic office-delivery label, deletes it in an
`ensure` block, and then calls `getShipmentStatuses` to verify that Econt
recorded a `canceled` tracking event. All three interactions are stored in
`econt_demo/label_create_and_delete.yml`; the generated description and
shipment number are filtered.

The example requires an additional, deliberate opt-in:

```bash
ECONT_LIVE_TESTS=1 ECONT_MUTATING_LIVE_TESTS=1 \
  bundle exec rspec spec/live/label_mutation_contract_spec.rb
```

Econt retains the cancelled label in status history. The example therefore
fails unless the final response contains a tracking event whose destination
type is `canceled`.

## Mutation cleanup inventory

Cleanup cancels disposable labels; it does not erase their historical records.
The inventory is based on the documented
[LabelService and ShipmentService](https://ee.econt.com/services/Shipments/),
[ProfileService](https://ee.econt.com/services/Profile/), and
[ThreeWayLogisticsService](https://ee.econt.com/services/ThreeWayLogistics/).

### Clear cleanup paths for disposable, uncollected labels

| Endpoint | Scenario and cleanup | Recording status |
| --- | --- | --- |
| Create label and delete labels | Create without courier-request times, delete, query the `canceled` tracking event | Existing demo recording verifies cleanup |

The verified example lives in `spec/live/label_mutation_contract_spec.rb`.
Cleanup runs in `ensure`; deletion errors or a missing cancellation event fail
the example. If creation times out before returning an identifier, account
reconciliation is required before retrying.

Update-label and batch-create mutation specs were removed after the demo API
acknowledged the same `deleteLabels` operation but continued to report `prepared`
through six subsequent status reads. Their cleanup call used the same endpoint
and shipment-number array payload as the verified example. The differing status
responses are a demo API inconsistency; the recordings do not establish why it
occurs or independently confirm cancellation for those scenarios.

### Suggested cleanup with uncertain effectiveness

| Endpoint/action | Suggested path | What remains unverified |
| --- | --- | --- |
| Update label | Update only a fresh disposable label, delete all returned numbers, query cancellation | Deletion was acknowledged, but six status reads remained `prepared`; the live spec was removed |
| Create labels synchronously | Collect all successful batch identifiers, delete each, query cancellation | Deletion was acknowledged for both labels, but six status reads remained `prepared`; the live spec was removed |
| Bulk update labels | Create disposable labels, make non-financial edits, delete every original and replacement number | The nested success model is typed, but batch edition side effects and replacement-number behavior still need live verification before automating cleanup |
| Grouping | Group only fresh disposable labels, call `groupingCancelation`, then delete the original labels and any surviving group label | There is an explicit undo endpoint, but status values, restoration of members, and group-label deletion behavior are not clearly documented |
| Grouping cancellation | Run only as the undo of a disposable group | No guarantee that cancellation erases the group or restores every member exactly |
| Set ITU code | Apply only to a fresh disposable label, then delete that label | Deletion is not documented to reverse code registration; no documented code-unset operation |
| Courier request, including times on label creation/update | Delete attached disposable labels and arrange cancellation of the courier request with the carrier | Deleting labels is not documented to cancel the request or courier visit; no courier-request cancellation endpoint is exposed |
| `updateLabel` with `destroy: true` | Carrier-confirmed procedure using disposable fixtures | The flag has no sufficient documented semantics to treat it as a reliable cleanup or rollback operation |

These are proposals without live mutation specs. Obtain a confirmed cleanup
contract before recording them; querying a status alone is not undo.

### No obvious API cleanup path

| Endpoint/action | Missing inverse |
| --- | --- |
| Create COD agreement (`createCDAgreement`) | No agreement revoke/delete endpoint in the published service |
| Three-way logistics | No documented undo for the complete logistics operation; deleting one generated label would not establish rollback of all side effects |
| Label payment blocking, payment instructions, or financial editions | No general payment-release/refund/edition-rollback endpoint; deleting a label does not establish financial rollback |

These require carrier-managed reset or explicitly disposable pre-provisioned
fixtures. They remain covered offline rather than by automatic live mutations.
