# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class ShipmentStatusService < Econt::Model
        field :type, type: :string
        field :description, type: :string
        field :count, type: :float
        field :payment_side, type: :string
        field :price, type: :float
        field :currency, type: :string
      end
    end
  end
end
