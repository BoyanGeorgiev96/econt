# frozen_string_literal: true

require "faraday"

module Econt
  # TODO: add description
  class Client
    BASE_URL = "https://api.imgur.com/3/"

    attr_reader :api_key, :adapter

    def initialize(api_key:, adapter: Faraday.default_adapter)
      @api_key = api_key
      @adapter = adapter
    end

    def connection
      @connection ||= Faraday.new(BASE_URL) do |conn|
        conn.request :json
        conn.response :json, content_type: "application/json"
        conn.adapter adapter
        conn.headers["Authorization"] = "Bearer #{api_key}" if api_key
      end
    end
  end
end
