# frozen_string_literal: true

module Econt
  module Services
    class ThreeWayLogistics < Resource
      autoload :Profile, "econt/services/three_way_logistics/three_way_logistics"
      def self.resource_url
        "ThreeWayLogistics"
      end
    end
  end
end
