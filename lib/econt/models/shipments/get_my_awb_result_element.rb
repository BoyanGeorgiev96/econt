# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class GetMyAwbResultElement < Econt::Model
        collection_key :results

        field :shipment_number, type: :string
        field :sender_name, type: :string
        field :status, type: :string
        field :created_date, type: :datetime
        field :accepted_date, type: :datetime
        field :cd_amount, type: :float
        field :courier_service_amount, type: :float
        field :courier_service_master_payer, type: :string
        field :receiver_phone, type: :string
        field :cd_currency, type: :string
        field :courier_service_currency, type: :string
      end
    end
  end
end
