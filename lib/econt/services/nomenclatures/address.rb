# frozen_string_literal: true

module Econt
  module Services
    module Nomenclatures
      # add docs
      class Address < Econt::ServiceResource
        include Econt::Services::Nomenclatures

        resource_type 'Address'

        # POST /services/Nomenclatures/AddressService.validateAddress.json(.soap?wsdl)
        def validate_address(address)
          address = address_to_hash(address)
          response = post('validateAddress', body: { address: address })
          resource(response, Econt::Models::Nomenclatures::AddressValidationResponse)
        end

        # POST /services/Nomenclatures/AddressService.addressServiceTimes.json(.soap?wsdl)
        def address_service_times(city:, address:, date:, shipment_type:)
          response = post('addressServiceTimes', body: {
                            city: city,
                            address: address,
                            date: date,
                            shipment_type: shipment_type
                          })
          collection(response, Econt::Models::Nomenclatures::WorkingDateTime)
        end

        # POST /services/Nomenclatures/AddressService.getNearestOffices.json(.soap?wsdl)
        def get_nearest_offices(address:, shipment_type:)
          response = post('getNearestOffices', body: { address: address, shipment_type: shipment_type })
          collection(response, Econt::Models::Nomenclatures::Office)
        end

        private

        def address_to_hash(address)
          if address.is_a?(Econt::Models::Nomenclatures::Address)
            address.to_h
          else
            Econt::Models::Nomenclatures::Address.new(address).to_h
          end
        end
      end
    end
  end
end
