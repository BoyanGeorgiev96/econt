# frozen_string_literal: true

module Econt
  module Models
    class Error < Econt::Model
      field :type, type: :string
      field :message, type: :string
      field :fields, type: :array
      field :inner_errors, type: :array, of: Econt::Models::Error

      class << self
        def build_from(source)
          return unless error_body?(source)

          new(source)
        end

        def error_body?(source)
          return false unless source.is_a?(Hash)

          has_key?(source, :type) && (has_key?(source, :fields) || has_key?(source, :inner_errors))
        end

        private

        def has_key?(hash, key)
          hash.key?(key) || hash.key?(Econt::Util.camel_case(key.to_s))
        end
      end

      def fields
        Array(@attributes[:fields])
      end

      def inner_errors
        Array(@attributes[:inner_errors]).map do |error|
          error.is_a?(Econt::Models::Error) ? error : Econt::Models::Error.new(error)
        end
      end

      def messages
        [
          message,
          *inner_errors.flat_map(&:messages)
        ].reject { |value| value.to_s.strip.empty? }
      end

      def full_message
        messages.join(' ')
      end
    end
  end
end
