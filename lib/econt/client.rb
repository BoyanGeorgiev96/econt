# frozen_string_literal: true

require 'faraday'
require 'json'
require 'base64'
require 'logger'

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

    attr_accessor :username, :password, :base_url, :adapter,
                  :acronyms, :replace_acronym_defaults,
                  :debug, :debug_bodies, :debug_logger,
                  :open_timeout, :read_timeout, :write_timeout

    def initialize
      @base_url = 'https://demo.econt.com/ee/services/' # Default to demo
      @adapter = Faraday.default_adapter
      @acronyms = {} # nil to disable, {} to keep defaults
      @replace_acronym_defaults = false
      @debug = false
      @debug_bodies = false
      @debug_logger = nil
      @open_timeout = 30
      @read_timeout = 30
      @write_timeout = 30
    end

    def add_acronyms(hash)
      @acronyms = (@acronyms || {}).merge(hash.transform_keys(&:to_s))
    end

    def setup_connection!
      validate_credentials!

      @connection = Faraday.new(base_url, ssl: { verify: true }) do |conn|
        configure_timeouts(conn)
        conn.use Econt::CamelCaseMiddleware,
                 acronyms: @acronyms,
                 replace_defaults: @replace_acronym_defaults
        conn.request :json
        conn.response :json, content_type: 'application/json'
        configure_debug_logging(conn) if debug
        conn.adapter adapter
        configure_headers(conn)
      end
    end

    def connection
      @connection || raise('Connection is not initialized. Call Econt::Client.configure first.')
    end

    private

    def configure_debug_logging(connection)
      connection.response :logger,
                          debug_logger || Logger.new($stdout),
                          headers: true,
                          bodies: debug_bodies do |formatter|
        formatter.filter(encoded_credentials, '<ECONT_BASIC_TOKEN>')
        formatter.filter(username.to_s, '<ECONT_USERNAME>')
        formatter.filter(password.to_s, '<ECONT_PASSWORD>')
      end
    end

    def configure_timeouts(connection)
      connection.options.open_timeout = open_timeout
      connection.options.timeout = read_timeout
      connection.options.write_timeout = write_timeout if connection.options.respond_to?(:write_timeout=)
    end

    def configure_headers(connection)
      connection.headers['Authorization'] = "Basic #{encoded_credentials}"
      connection.headers['User-Agent'] = "EcontRubyClient/#{Econt::VERSION}"
    end

    def validate_credentials!
      creds_missing = [username, password].any? { |credential| credential.to_s.empty? }
      raise 'Username and password must be set' if creds_missing
    end

    def encoded_credentials
      Base64.strict_encode64("#{username}:#{password}")
    end
  end
end
