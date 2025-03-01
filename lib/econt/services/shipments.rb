# frozen_string_literal: true

module Econt
  module Services
    class Shipments < Resource
      autoload :Label, "econt/services/shipments/label"
      autoload :Shipment, "econt/services/shipments/shipment"
      def self.resource_url
        "Shipments"
      end
    end
  end
end
