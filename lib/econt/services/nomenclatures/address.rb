# frozen_string_literal: true

module Econt
  module Services
    module Nomenclatures
      class Address < Econt::Resource
        include Econt::Services::Nomenclatures
        resource_type 'Address'

        # GET /services/Nomenclatures/AddressService.getCountries.json(.soap?wsdl)
        def validate_address
          get('validateAddress')
        end

        # GET /services/Nomenclatures/AddressService.getStreets.json(.soap?wsdl)
        def address_service_times
          get('addressServiceTimes')
        end

        # GET /services/Nomenclatures/AddressService.getNearestOffices.json(.soap?wsdl)
        def get_nearest_offices
          get('getNearestOffices')
        end
      end
    end
  end
end
