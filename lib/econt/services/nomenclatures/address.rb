# frozen_string_literal: true

module Econt
  module Services
    module Nomenclatures
      # add docs
      class Address < Econt::ServiceResource
        include Econt::Services::Nomenclatures
        resource_type 'Address'

        # POST /services/Nomenclatures/AddressService.getCountries.json(.soap?wsdl)
        def validate_address(address)
          address = address_to_json(address)
          post('validateAddress', body: { address: address })
        end

        # POST /services/Nomenclatures/AddressService.getStreets.json(.soap?wsdl)
        def address_service_times(city:, address:, date:, shipment_type:)
          post('addressServiceTimes', body: {
                 city: city,
                 address: address,
                 date: date,
                 shipment_type: shipment_type
               })
        end

        # POST /services/Nomenclatures/AddressService.getNearestOffices.json(.soap?wsdl)
        def get_nearest_offices(address:, shipment_type:)
          post('getNearestOffices', body: { address: address, shipment_type: shipment_type })
        end

        private

        def address_to_json(address)
          if address.is_a?(Econt::Models::Nomenclatures::Address)
            address.to_json
          else
            Econt::Models::Nomenclatures::Address.new(address).to_json
          end
        end
      end
    end
  end
end
