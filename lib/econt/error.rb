# frozen_string_literal: true

module Econt
  class Error < StandardError
    attr_reader :error, :status

    def initialize(message = nil, error: nil, status: nil)
      @error = error
      @status = status

      super(message || error_message || status_message || self.class.name)
    end

    private

    def error_message
      return unless error.respond_to?(:full_message)

      message = error.full_message
      message unless message.to_s.strip.empty?
    end

    def status_message
      return if status.nil?

      "Econt API request failed with status #{status}."
    end
  end

  # A request failed before a usable HTTP response was available.
  # The original adapter exception is retained as #cause and may contain secrets.
  class TransportError < Error; end

  # The client could not establish or maintain a connection.
  class ConnectionError < TransportError; end

  # The configured connection or request deadline was exceeded.
  class TimeoutError < TransportError; end

  # TLS negotiation or certificate verification failed.
  class SSLError < TransportError; end
end
