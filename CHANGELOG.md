# Changelog

## Unreleased

## 0.1.1 — 2026-10-12

- Default demo API requests to HTTPS and update production configuration examples.
- Explicitly enable TLS certificate verification.
- Clarify that Econt supports HTTPS with Basic authentication; client-certificate
  authentication is a separate unsupported feature. Explicit HTTP URLs remain
  configurable, but TLS failures never cause an HTTP fallback.
