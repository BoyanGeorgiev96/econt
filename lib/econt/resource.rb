# frozen_string_literal: true

module Econt
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def resource_url(format = "json")
      "#{self.class.resource_url}.#{resource_type}Service.#{format}"
    end

    private

    ERROR_MESSAGES = {
      400 => "Your request was malformed.",
      401 => "You did not supply valid authentication credentials.",
      403 => "You are not allowed to perform that action.",
      404 => "No results were found for your request.",
      429 => "Your request exceeded the API rate limit.",
      500 => "We were unable to perform the request due to server-side problems.",
      503 => "You have been rate-limited for sending more than 20 requests per second."
    }.freeze

    def get(url, params: {}, headers: {})
      handle_response client.connection.get(url, params, headers)
    end

    def post(url, body:, headers: {})
      handle_response client.connection.post(url, body, headers)
    end

    def patch(url, body:, headers: {})
      handle_response client.connection.patch(url, body, headers)
    end

    def put(url, body:, headers: {})
      handle_response client.connection.put(url, body, headers)
    end

    def delete(url, params: {}, headers: {})
      handle_response client.connection.delete(url, params, headers)
    end

    def handle_response(response)
      error_message = ERROR_MESSAGES[response.status]
      raise Error, error_message if error_message

      response
    end
  end
end
