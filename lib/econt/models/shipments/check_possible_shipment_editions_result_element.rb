# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class CheckPossibleShipmentEditionsResultElement < Econt::Model
        field :possible_shipment_editions, type: :array, of: :string
        field :shipment_num, type: :integer
      end
    end
  end
end
