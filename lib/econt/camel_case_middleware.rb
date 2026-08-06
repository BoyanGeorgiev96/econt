# frozen_string_literal: true

require 'faraday'

module Econt
  class CamelCaseMiddleware < Faraday::Middleware
    DEFAULT_ACRONYMS = {
      'id' => 'ID',
      'lc' => 'LC'
    }.freeze

    def initialize(app, acronyms: {}, replace_defaults: false)
      super(app)
      @acronyms =
        if acronyms.nil?
          {}
        elsif replace_defaults
          acronyms.transform_keys(&:to_s)
        else
          DEFAULT_ACRONYMS.merge(acronyms.transform_keys(&:to_s))
        end
      # value (UPPER) -> lowercase key
      @acronym_reverse = @acronyms.each_with_object({}) { |(k, v), h| h[v] = k }
    end

    def call(env)
      env.body = deep_transform_keys(env.body) { |key| to_camel_case(key) } if env.body.is_a?(Hash)
      @app.call(env)
    end

    def on_complete(env)
      return unless env.body.is_a?(Hash)

      env.body = deep_transform_keys(env.body) { |key| to_snake_case(key) }
    end

    private

    # snake_case -> camelCase (request)
    def to_camel_case(key)
      parts = key.to_s.split('_')
      return key.to_s if parts.empty?

      first = parts.shift
      first + parts.map { |p| @acronyms.fetch(p, p.capitalize) }.join
    end

    # camelCase/PascalCase/acronyms -> snake_case (response) with acronym support
    def to_snake_case(key)
      str = key.to_s
      # Protect acronyms (longest first)
      @acronym_reverse.keys.sort_by { |x| -x.length }.each do |acro|
        str = str.gsub(/#{acro}(?=[A-Z]|$)/) { "_#{@acronym_reverse[acro]}_" }
      end
      str = str
            .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .downcase
      str.gsub(/__+/, '_').sub(/^_/, '').sub(/_$/, '')
    end

    def deep_transform_keys(obj, &block)
      case obj
      when Array
        obj.map { |item| deep_transform_keys(item, &block) }
      when Hash
        obj.each_with_object({}) { |(k, v), h| h[yield(k)] = deep_transform_keys(v, &block) }
      else
        obj
      end
    end
  end
end
