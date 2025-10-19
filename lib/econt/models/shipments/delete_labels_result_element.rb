# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class DeleteLabelsResultElement < Econt::Model
        field :shipment_num, type: :string
        field :error, type: Econt::Models::Error
      end
    end
  end
end
