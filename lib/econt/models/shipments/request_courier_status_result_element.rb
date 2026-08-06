# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class RequestCourierStatusResultElement < Econt::Model
        collection_key :request_courier_status

        field :status, type: Econt::Models::Shipments::RequestCourierStatus
        field :error, type: Econt::Models::Error
      end
    end
  end
end
