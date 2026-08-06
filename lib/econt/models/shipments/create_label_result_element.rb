# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class CreateLabelResultElement < Econt::Model
        collection_key :results

        field :label, type: Econt::Models::Shipments::ShipmentStatus
        field :error, type: Econt::Models::Error
        field :pay_after_accept_ignored, type: :string
      end
    end
  end
end
