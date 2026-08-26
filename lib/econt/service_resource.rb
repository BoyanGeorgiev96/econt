# frozen_string_literal: true

module Econt
  class ServiceResource
    attr_reader :client

    class << self
      def resource_type(value = self.name.split('::').last)
        @resource_type = value
      end
    end

    def initialize(client: Econt::Client.instance)
      @client = client || raise('Econt::Client is not configured. Call `Econt::Client.configure` first.')
    end

    def resource_url
      "#{service_url}/#{self.class.resource_type}Service"
    end

    private

    ERROR_MESSAGES = {
      400 => 'Your request was malformed.',
      401 => 'You did not supply valid authentication credentials.',
      403 => 'You are not allowed to perform that action.',
      404 => 'No results were found for your request.',
      429 => 'Your request exceeded the API rate limit.',
      500 => 'We were unable to perform the request due to server-side problems.',
      503 => 'You have been rate-limited for sending more than 20 requests per second.'
    }.freeze

    def get(url, params: {}, headers: {})
      response_for client.connection.get(url_for(url), params, headers)
    end

    def post(url, body: nil, headers: {})
      response_for client.connection.post(url_for(url), body, headers)
    end

    def patch(url, body:, headers: {})
      response_for client.connection.patch(url_for(url), body, headers)
    end

    def put(url, body:, headers: {})
      response_for client.connection.put(url_for(url), body, headers)
    end

    def delete(url, params: {}, headers: {})
      response_for client.connection.delete(url_for(url), params, headers)
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
