# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class ShipmentEditionResponseElement < Econt::Model
        field :shipment_num, type: :integer
        field :edition_num, type: :integer
        field :edition_type, type: :string
        field :edition_error, type: :string
        field :price, type: :string
        field :currency, type: :string
      end
    end
  end
end
