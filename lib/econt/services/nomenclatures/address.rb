# frozen_string_literal: true

module Econt
  module Services
    module Nomenclatures
      class Address < Econt::ServiceResource
        include Econt::Services::Nomenclatures

        resource_type 'Address'

        # POST /services/Nomenclatures/AddressService.validateAddress.json(.soap?wsdl)
        # Validate and normalize an address.
        # @note Read. Does not change shipment state.
        # @param address [Hash, Econt::Models::Nomenclatures::Address] Address fields; the argument is positional.
        # @return [Econt::Models::Nomenclatures::AddressValidationResponse]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#validate_address Ruby usage and parameters
        # @example After configuring Econt::Client
        #   addresses = Econt::Services::Nomenclatures::Address.new
        #   validation = addresses.validate_address(city: { id: 41 }, street: 'Витоша', num: '1')
        def validate_address(address)
          address = address_to_hash(address)
          response = post('validateAddress', body: { address: address })
          resource(response, Econt::Models::Nomenclatures::AddressValidationResponse)
        end

        # POST /services/Nomenclatures/AddressService.addressServiceTimes.json(.soap?wsdl)
        # Look up address service availability for a date and shipment type.
        # @note Read. Does not change shipment state.
        # @param city [Hash] City fields.
        # @param address [Hash] Address fields.
        # @param date [String] Requested service date in the carrier format.
        # @param shipment_type [String] Carrier shipment type, such as pack.
        # @return [Econt::Models::Nomenclatures::AddressServiceTimesResponse]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#address_service_times Ruby usage and parameters
        # @example After configuring Econt::Client
        #   addresses = Econt::Services::Nomenclatures::Address.new
        #   times = addresses.address_service_times(
        #     city: { id: 41 }, address: address_payload,
        #     date: '2026-10-12', shipment_type: 'pack'
        #   )
        def address_service_times(city:, address:, date:, shipment_type:)
          response = post('addressServiceTimes', body: {
                            city: city,
                            address: address,
                            date: date,
                            shipment_type: shipment_type
                          })
          resource(response, Econt::Models::Nomenclatures::AddressServiceTimesResponse)
        end

        # POST /services/Nomenclatures/AddressService.getNearestOffices.json(.soap?wsdl)
        # Find offices near an address for a shipment type.
        # @note Read. Does not change shipment state.
        # @param address [Hash] Address fields.
        # @param shipment_type [String] Carrier shipment type.
        # @return [Econt::Collection<Econt::Models::Nomenclatures::Office>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_nearest_offices Ruby usage and parameters
        # @example After configuring Econt::Client
        #   addresses = Econt::Services::Nomenclatures::Address.new
        #   offices = addresses.get_nearest_offices(address: address_payload, shipment_type: 'pack')
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
