# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class CustomsListElement < Econt::Model
        field :shipment_number, type: :integer
        field :reason, type: :string
        field :pdf_url, type: :string
      end
    end
  end
end
