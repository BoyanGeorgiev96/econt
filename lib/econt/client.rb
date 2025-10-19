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

    attr_accessor :username, :password, :base_url, :adapter,
                  :acronyms, :replace_acronym_defaults,
                  :debug

    def initialize
      @base_url = 'http://demo.econt.com/ee/services/' # Default to demo
      @adapter = Faraday.default_adapter
      @acronyms = {} # nil to disable, {} to keep defaults
      @replace_acronym_defaults = false
      @debug    = false
    end

    def add_acronyms(hash)
      @acronyms = (@acronyms || {}).merge(hash.transform_keys(&:to_s))
    end

    def setup_connection!
      validate_credentials!

      @connection = Faraday.new(base_url) do |conn|
        conn.use Econt::CamelCaseMiddleware,
                 acronyms: @acronyms,
                 replace_defaults: @replace_acronym_defaults
        conn.request :json
        conn.response :json, content_type: 'application/json'
        conn.response :logger, Logger.new($stdout), bodies: true if debug
        conn.adapter adapter
        conn.headers['Authorization'] = "Basic #{encoded_credentials}"
        conn.headers['User-Agent'] = "EcontRubyClient/#{Econt::VERSION}"
      end
    end

    def connection
      @connection || raise('Connection is not initialized. Call Econt::Client.configure first.')
    end

    private

    def validate_credentials!
      creds_missing = [username, password].any? { |cred| cred.nil? || cred.empty? }
      raise 'Username and password must be set' if creds_missing
    end

    def encoded_credentials
      Base64.strict_encode64("#{username}:#{password}")
    end
  end
end
