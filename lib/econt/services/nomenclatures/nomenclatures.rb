# frozen_string_literal: true

module Econt
  module Services
    module Nomenclatures
      class Nomenclatures < ServiceResource
        include Econt::Services::Nomenclatures

        def get_countries
          response = post('getCountries')
          collection(response, Econt::Models::Nomenclatures::Country)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getCountries.json(.soap?wsdl)
        end

        def get_cities(country_code:)
          response = post('getCities', body: { country_code: country_code })
          collection(response, Econt::Models::Nomenclatures::City)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getCities.json(.soap?wsdl)
        end

        def get_offices(country_code:, city_id: nil, show_cargo_receptions: nil, show_lc: nil, serving_receptions: nil)
          response = post('getOffices', body: {
                            country_code: country_code,
                            city_id: city_id,
                            show_cargo_receptions: show_cargo_receptions,
                            show_lc: show_lc,
                            serving_receptions: serving_receptions
                          })
          collection(response, Econt::Models::Nomenclatures::Office)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getOffices.json(.soap?wsdl)
        end

        def get_streets(city_id: nil)
          response = post('getStreets', body: { city_id: city_id })
          collection(response, Econt::Models::Nomenclatures::Street)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getStreets.json(.soap?wsdl)
        end

        def get_quarters(city_id: nil)
          response = post('getQuarters', body: { city_id: city_id })
          collection(response, Econt::Models::Nomenclatures::Quarter)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getQuarters.json(.soap?wsdl)
        end
      end
    end
  end
end
