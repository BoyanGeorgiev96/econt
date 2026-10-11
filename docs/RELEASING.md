# Releasing

Ordinary pushes and pull requests only test and package the gem. They never
publish it.

The manual `Release gem` workflow is intentionally gated by all of the
following:

1. Select an existing `vVERSION` tag when dispatching the workflow.
2. The tag must exactly match `Econt::VERSION`.
3. Type `publish` into the confirmation input.
4. Set the repository variable `RUBYGEMS_TRUSTED_PUBLISHING_ENABLED` to `true`.
5. Configure the `release` GitHub environment and a RubyGems pending trusted
   publisher for this repository and workflow.

Until those repository-side settings exist, the publish job is skipped rather
than failing normal CI. Trusted Publishing uses GitHub OIDC; no long-lived
RubyGems API key belongs in repository secrets.

Before creating a tag, run:

```bash
bundle exec rake
bundle exec rbs -r date -I sig validate
bin/package_smoke_test
bin/check_release_tag v0.1.0
```

Then inspect the built gem contents and confirm README examples against the
demo environment using sanitized contract recordings. Publishing is irreversible,
so do not reuse a released version number.

The package smoke test uses dependencies installed by `bundle install`, including
project-local Bundler caches. Its final subprocess disables Bundler and loads the
built gem from a temporary installation outside the source checkout.
