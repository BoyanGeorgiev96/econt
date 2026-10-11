# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class RequestCourierResponse < Econt::Model
        field :courier_request_id, type: :string
        field :warnings, type: :string
        field :delayed_request_warning, type: :string
      end
    end
  end
end
