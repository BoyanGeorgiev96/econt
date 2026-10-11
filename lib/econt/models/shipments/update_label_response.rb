# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class UpdateLabelResponse < Econt::Model
        field :label, type: Econt::Models::Shipments::ShipmentStatus
      end
    end
  end
end
