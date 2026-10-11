# frozen_string_literal: true

module Econt
  class ServiceResource
    attr_reader :client

    class << self
      def resource_type(value = name.split('::').last)
        @resource_type = value
      end
    end

    def initialize(client: Econt::Client.instance)
      @client = client || raise('Econt::Client is not configured. Call `Econt::Client.configure` first.')
    end

    def resource_url
      "#{service_url}/#{self.class.resource_type}Service"
    end

    ERROR_MESSAGES = {
      400 => 'Your request was malformed.',
      401 => 'You did not supply valid authentication credentials.',
      403 => 'You are not allowed to perform that action.',
      404 => 'No results were found for your request.',
      429 => 'Your request exceeded the API rate limit.',
      500 => 'We were unable to perform the request due to server-side problems.',
      503 => 'You have been rate-limited for sending more than 20 requests per second.'
    }.freeze

    private

    def get(url, params: {}, headers: {})
      response_for(execute_request { client.connection.get(url_for(url), params, headers) })
    end

    def post(url, body: {}, headers: {})
      response_for(execute_request { client.connection.post(url_for(url), body, headers) })
    end

    def post_raw(url, body:, headers: {})
      json_headers = { 'Content-Type' => 'application/json' }.merge(headers)
      json_body = JSON.generate(body)
      response_for(execute_request { client.connection.post(url_for(url), json_body, json_headers) })
    end

    def patch(url, body:, headers: {})
      response_for(execute_request { client.connection.patch(url_for(url), body, headers) })
    end

    def put(url, body:, headers: {})
      response_for(execute_request { client.connection.put(url_for(url), body, headers) })
    end

    def delete(url, params: {}, headers: {})
      response_for(execute_request { client.connection.delete(url_for(url), params, headers) })
    end

    def execute_request
      yield
    rescue Faraday::ConnectionFailed => e
      raise Econt::ConnectionError.new('Econt API connection failed.'), cause: e
    rescue Faraday::TimeoutError => e
      raise Econt::TimeoutError.new('Econt API request timed out.'), cause: e
    rescue Faraday::SSLError => e
      raise Econt::SSLError.new('Econt API TLS connection failed.'), cause: e
    end

    def url_for(url, format = 'json')
      "#{resource_url}.#{url}.#{format}"
    end

    def response_for(response)
      error = error_from(response.body)
      raise Error.new(error: error, status: response.status) if error && server_error?(response)
      return response if error

      error_message = ERROR_MESSAGES[response.status]
      raise Error.new(error_message, status: response.status) if error_message
      raise Error.new(status: response.status) unless successful_response?(response)

      response
    end

    def collection(response, model)
      model.collection(response.body)
    end

    def resource(response, model, key: nil)
      model.build(response.body, key: key)
    end

    def error_from(body)
      Econt::Models::Error.build_from(body)
    end

    def successful_response?(response)
      response.status.to_i.between?(200, 299)
    end

    def server_error?(response)
      response.status.to_i.between?(500, 599)
    end
  end
end
