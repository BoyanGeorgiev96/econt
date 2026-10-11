# frozen_string_literal: true

require_relative 'lib/econt/version'

Gem::Specification.new do |spec|
  spec.name = 'econt'
  spec.version = Econt::VERSION
  spec.authors = ['Boyan Georgiev']
  spec.email = ['bbgeorgiev96@gmail.com']

  spec.summary = 'Econt API client for Ruby.'
  spec.description = 'A Faraday-backed Ruby client for Econt labels, shipment tracking, courier requests, ' \
                     'addresses, offices, profiles, and reports.'
  spec.homepage = 'https://github.com/BoyanGeorgiev96/econt'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/main"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/main/docs/API.md"
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir[
    'CHANGELOG.md',
    'CODE_OF_CONDUCT.md',
    'CONTRIBUTING.md',
    'LICENSE.txt',
    'README.md',
    'SECURITY.md',
    'docs/**/*.md',
    'lib/**/*.rb',
    'sig/**/*.rbs'
  ]
  spec.require_paths = ['lib']

  spec.add_dependency 'base64', '~> 0.3'
  spec.add_dependency 'faraday', '>= 2.14', '< 3.0'
end
