# frozen_string_literal: true

require 'faraday'
require 'json'
require 'base64'

module Econt
  class Client
    class << self
      attr_reader :instance

      def configure
        @instance ||= new
        yield(@instance) if block_given?
        @instance.setup_connection!
      end

      def connection
        instance&.connection || raise('Econt::Client is not configured. Call Econt::Client.configure first.')
      end
    end

    attr_accessor :username, :password, :base_url, :adapter, :debug

    def initialize
      @base_url = 'https://demo.econt.com/ee/services/' # Default to demo
      @adapter = Faraday.default_adapter
    end

    def setup_connection!
      raise 'Username and password must be set' unless username && password

      @connection = Faraday.new(base_url) do |conn|
        conn.use Econt::CamelCaseMiddleware # Auto-convert snake_case to camelCase
        conn.request :json
        conn.response :json, content_type: 'application/json'
        conn.response :logger, Logger.new($stdout), bodies: true if debug
        # conn.response :gzip # ✅ Add this to enable gzip decompression
        conn.adapter adapter
        conn.headers['Authorization'] = "Basic #{encoded_credentials}"
      end
    end

    def connection
      @connection || raise('Connection is not initialized. Call Econt::Client.configure first.')
    end

    private

    def encoded_credentials
      Base64.strict_encode64("#{username}:#{password}")
    end
  end
end
