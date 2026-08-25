# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class Address < Econt::Model
        field :id, type: :integer
        field :city, type: Econt::Models::Nomenclatures::City
        field :full_address, type: :string
        field :full_address_en, type: :string
        field :quarter, type: :string
        field :street, type: :string
        field :num, type: :string
        field :other, type: :string
        field :location, type: Econt::Models::Nomenclatures::GeoLocation
        field :zip, type: :string
        field :hezid, type: :string
        field :validation_status, type: :string
        field :service_info, type: Econt::Models::Nomenclatures::AddressServiceInfo

        def validate
          address_service.validate_address(@attributes)
        end

        def get_nearest_offices(shipment_type)
          address_service.get_nearest_offices(@attributes, shipment_type)
        end

        def address_service
          @address_service ||= Services::Nomenclatures::Address.new
        end
      end
    end
  end
end
