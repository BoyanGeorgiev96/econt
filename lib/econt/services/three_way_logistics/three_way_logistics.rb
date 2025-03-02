# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class ThreeWayLogistics < Resource
        include Econt::Services::ThreeWayLogistics
        resource_type 'ThreeWayLogistics'

        def three_way_logistics
          post('threeWayLogistics')
        end
      end
    end
  end
end
