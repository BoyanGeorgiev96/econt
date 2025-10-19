# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class UpdateLabelsResultElement < Econt::Model
        field :error, type: Econt::Models::Error
        # doesn't exist in the API documentation???
        # field :labels, type: Econt::Models::Shipments::UpdateLabelResponse
      end
    end
  end
end
