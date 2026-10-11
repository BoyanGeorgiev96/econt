# frozen_string_literal: true

module Econt
  module Services
    module ThreeWayLogistics
      class ThreeWayLogistics < ServiceResource
        include Econt::Services::ThreeWayLogistics

        resource_type 'ThreeWayLogistics'

        # Submit a three-way logistics request using legacy snake_case fields without camelCase conversion.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param attributes [Hash] Legacy request fields as keywords; see ThreeWayLogisticsRequest for available
        #   field names.
        # @return [Econt::Models::ThreeWayLogistics::ThreeWayLogisticsResponse]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#three_way_logistics Ruby usage and parameters
        # @example After configuring Econt::Client
        #   logistics = Econt::Services::ThreeWayLogistics::ThreeWayLogistics.new
        #   result = logistics.three_way_logistics(**logistics_payload)
        def three_way_logistics(**attributes)
          response = post_raw('threeWayLogistics', body: attributes.transform_keys(&:to_s))
          resource(response, Econt::Models::ThreeWayLogistics::ThreeWayLogisticsResponse)
        end
      end
    end
  end
end
