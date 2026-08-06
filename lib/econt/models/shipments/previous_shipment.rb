# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class PreviousShipment < Econt::Model
        field :shipment_number, type: :string
        field :reason, type: :string
        field :pdf_url, type: :string
      end
    end
  end
end
