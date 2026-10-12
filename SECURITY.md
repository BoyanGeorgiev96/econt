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

## HTTPS transport and credentials

The client defaults to `https://demo.econt.com/ee/services/`. Use
`https://ee.econt.com/services/` for production. Econt's documentation lists HTTP
example URLs but explicitly supports SSL connections with Basic authentication.
The lack of client-certificate authentication does not mean HTTPS is unavailable.

TLS certificate verification is enabled by default. The client does not fall
back to HTTP when TLS fails. Explicit HTTP base URLs remain configurable for
compatibility, but they transmit credentials and shipment data without TLS.
Use HTTPS and do not disable certificate verification.

Run requests only from server-side infrastructure. Never call Econt directly
from browser code. Keep credentials out of source control, rotate them if
exposed, and limit access to application logs and VCR cassettes.

Debug mode filters the configured username, password, and Basic token. Request
and response bodies are disabled by default because they may contain personal
data. Enabling `debug_bodies` is an explicit decision to log that data and
should be limited to short-lived local diagnosis.
