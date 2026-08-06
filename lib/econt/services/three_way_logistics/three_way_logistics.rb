# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class ThreeWayLogistics < ServiceResource
        include Econt::Services::ThreeWayLogistics
        resource_type 'ThreeWayLogistics'

        def three_way_logistics
          response = post('threeWayLogistics')
          resource(response, Econt::Models::ThreeWayLogistics::ThreeWayLogistics)
        end
      end
    end
  end
end
