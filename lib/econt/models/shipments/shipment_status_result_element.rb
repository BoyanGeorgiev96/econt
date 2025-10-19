# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class ShipmentStatusResultElement < Econt::Model
        field :status, type: Econt::Models::Shipments::ShipmentStatus
        field :error, type: Econt::Models::Error
      end
    end
  end
end
