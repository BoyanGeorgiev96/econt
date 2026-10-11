# Security policy

## Reporting a vulnerability

Use GitHub's private vulnerability reporting for this repository when it is
available. If it is not enabled, open a public issue containing only a request
for a private contact channel—do not include exploit details, credentials,
personal data, or carrier responses in that issue.

Reports are reviewed on a best-effort basis, usually on weekends. This
community project cannot promise a response or remediation deadline. Please do
not publicly disclose an unresolved vulnerability before a private discussion
has taken place.

Only the latest released version receives security fixes. Pull requests are
welcome after coordinated disclosure.

## Econt transport limitation

Econt documents its demo and production service URLs as HTTP endpoints using
HTTP Basic authentication. Consequently, credentials and shipment data are not
protected by TLS in transit. This gem preserves those documented URLs and does
not claim to solve that carrier-side limitation.

Run requests only from trusted server-side infrastructure and through a network
path whose risks you accept. Never call Econt directly from browser code. Keep
credentials out of source control, rotate them if exposed, and limit access to
application logs and VCR cassettes.

Debug mode filters the configured username, password, and Basic token. Request
and response bodies are disabled by default because they may contain personal
data. Enabling `debug_bodies` is an explicit decision to log that data and
should be limited to short-lived local diagnosis.
