# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class ShipmentTrackingEvent < Econt::Model
        field :is_receipt, type: :boolean
        field :destination_type, type: :string
        field :destination_details, type: :string
        field :destination_details_en, type: :string
        field :office_name, type: :string
        field :office_name_en, type: :string
        field :city_name, type: :string
        field :city_name_en, type: :string
        field :country_code, type: :string
        field :office_code, type: :string
        field :time, type: :datetime
      end
    end
  end
end
