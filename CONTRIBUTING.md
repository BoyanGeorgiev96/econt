# Contributing

Thank you for improving this community-maintained Econt client.

## Support expectations

Issues and pull requests are reviewed on a best-effort basis, usually on
weekends. There is no guaranteed response time, service-level agreement, or
commitment to implement feature requests. Focused pull requests for fixes and
documented endpoints are welcome. The MIT license also permits you to fork and
maintain behavior tailored to your application.

Use GitHub Issues for reproducible bugs, documentation gaps, and focused feature
proposals. Include the gem version, Ruby version, environment (demo or
production), the service method, expected behavior, and a minimal sanitized
example. Never include credentials, Authorization headers, real names, phone
numbers, addresses, shipment numbers, or unredacted carrier responses.

Security vulnerabilities belong in the private process described in
[SECURITY.md](SECURITY.md), not in a public issue.

## Pull requests

1. Open an issue first for a public API change or a large addition.
2. Keep changes focused and preserve Econt's documented casing at the HTTP
   boundary while exposing snake_case Ruby APIs.
3. Add request-payload and response-model specs.
4. Update RBS and public documentation when the API changes.
5. Run `bundle exec rake`, `bundle exec rbs validate`, and
   `bin/package_smoke_test`.

Normal tests must not contact Econt. Contract recordings are opt-in, must use
the demo environment, and must be carefully scrubbed before they are proposed.
Do not record state-changing label or courier operations without prior project
discussion.

By participating, you agree to follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
