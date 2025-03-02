# frozen_string_literal: true

require 'faraday'

module Econt
  class CamelCaseMiddleware < Faraday::Middleware
    def call(env)
      env.body = deep_transform_keys(env.body) { |key| to_camel_case(key) } if env.body.is_a?(Hash)
      @app.call(env)
    end

    private

    # Converts snake_case to camelCase
    def to_camel_case(key)
      key.to_s.split('_').inject { |memo, word| memo + word.capitalize }
    end

    # Recursively transform all hash keys
    def deep_transform_keys(hash, &block)
      case hash
      when Array
        hash.map { |item| deep_transform_keys(item, &block) }
      when Hash
        hash.each_with_object({}) do |(key, value), result|
          result[yield(key)] = deep_transform_keys(value, &block)
        end
      else
        hash
      end
    end
  end
end
