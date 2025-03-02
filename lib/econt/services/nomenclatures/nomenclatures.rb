# frozen_string_literal: true

module Econt
  module Services
    module Nomenclatures
      class Nomenclatures < Resource
        include Econt::Services::Nomenclatures
        resource_type 'Nomenclatures'

        def get_countries
          get('getCountries')
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getCountries.json(.soap?wsdl)
        end

        def get_cities(country_code:)
          post('getCities', body: { country_code: country_code })
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getCities.json(.soap?wsdl)
        end

        def get_offices
          get('getOffices')
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getOffices.json(.soap?wsdl)
        end

        def get_streets
          get('getStreets')
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getStreets.json(.soap?wsdl)
        end

        def get_quarters
          get('getQuarters')
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getQuarters.json(.soap?wsdl)
        end
      end
    end
  end
end
