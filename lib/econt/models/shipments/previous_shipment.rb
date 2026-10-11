# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class PreviousShipment < Econt::Model
        # Unlike the other shipment-number fields, Econt documents this as int.
        field :shipment_number, type: :integer
        field :reason, type: :string
        field :pdf_url, type: :string
      end
    end
  end
end
