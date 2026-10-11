# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class CreateLabelResultElement < Econt::Model
        collection_key :results

        field :label, type: Econt::Models::Shipments::ShipmentStatus
        field :error, type: Econt::Models::Error
        field :pay_after_accept_ignored, type: :string
        field :blocking_payment_url, type: :string
        field :courier_request_id, type: :integer
        field :delayed_delivery_warning, type: :string
        field :delayed_request_warning, type: :string
      end
    end
  end
end
