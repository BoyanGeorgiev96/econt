# frozen_string_literal: true

module Econt
  module Services
    module Nomenclatures
      class Nomenclatures < ServiceResource
        include Econt::Services::Nomenclatures

        # List countries available for delivery.
        # @note Read. Does not change shipment state.
        # @return [Econt::Collection<Econt::Models::Nomenclatures::Country>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_countries Ruby usage and parameters
        # @example After configuring Econt::Client
        #   nomenclatures = Econt::Services::Nomenclatures::Nomenclatures.new
        #   countries = nomenclatures.get_countries
        def get_countries
          response = post('getCountries')
          collection(response, Econt::Models::Nomenclatures::Country)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getCountries.json(.soap?wsdl)
        end

        # List cities for a country.
        # @note Read. Does not change shipment state.
        # @param country_code [String] ISO country code, such as BGR.
        # @return [Econt::Collection<Econt::Models::Nomenclatures::City>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_cities Ruby usage and parameters
        # @example After configuring Econt::Client
        #   nomenclatures = Econt::Services::Nomenclatures::Nomenclatures.new
        #   cities = nomenclatures.get_cities(country_code: 'BGR')
        def get_cities(country_code:)
          response = post('getCities', body: { country_code: country_code })
          collection(response, Econt::Models::Nomenclatures::City)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getCities.json(.soap?wsdl)
        end

        # Fetch cities and derive unique, sorted region names; this is a local helper, not a separate endpoint.
        # @note Read. Does not change shipment state.
        # @param country_code [String] Country code.
        # @param language [String, nil] Only en selects English names; nil and other values select native names.
        # @return [Array<String>] Unique, sorted region names; no #error? reader.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_regions Ruby usage and parameters
        # @example After configuring Econt::Client
        #   nomenclatures = Econt::Services::Nomenclatures::Nomenclatures.new
        #   regions = nomenclatures.get_regions(country_code: 'BGR', language: 'en')
        def get_regions(country_code:, language: nil)
          region_field = language.to_s.casecmp('en').zero? ? :region_name_en : :region_name
          cities = get_cities(country_code: country_code)
          cities.filter_map { |city| city.send(region_field) }.uniq.sort
        end

        # List offices with optional city and reception filters.
        # @note Read. Does not change shipment state.
        # @param country_code [String] Country code.
        # @param city_id [Integer, nil] City identifier.
        # @param show_cargo_receptions [Boolean, nil] Include cargo receptions.
        # @param show_lc [Boolean, nil] Carrier LC filter.
        # @param serving_receptions [Boolean, nil] Carrier serving-reception filter.
        # @return [Econt::Collection<Econt::Models::Nomenclatures::Office>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_offices Ruby usage and parameters
        # @example After configuring Econt::Client
        #   nomenclatures = Econt::Services::Nomenclatures::Nomenclatures.new
        #   offices = nomenclatures.get_offices(country_code: 'BGR', city_id: 41)
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

        # List streets, optionally restricted to a city.
        # @note Read. Does not change shipment state.
        # @param city_id [Integer, nil] City identifier.
        # @return [Econt::Collection<Econt::Models::Nomenclatures::Street>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_streets Ruby usage and parameters
        # @example After configuring Econt::Client
        #   nomenclatures = Econt::Services::Nomenclatures::Nomenclatures.new
        #   streets = nomenclatures.get_streets(city_id: 41)
        def get_streets(city_id: nil)
          response = post('getStreets', body: { city_id: city_id })
          collection(response, Econt::Models::Nomenclatures::Street)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getStreets.json(.soap?wsdl)
        end

        # List quarters, optionally restricted to a city.
        # @note Read. Does not change shipment state.
        # @param city_id [Integer, nil] City identifier.
        # @return [Econt::Collection<Econt::Models::Nomenclatures::Quarter>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_quarters Ruby usage and parameters
        # @example After configuring Econt::Client
        #   nomenclatures = Econt::Services::Nomenclatures::Nomenclatures.new
        #   quarters = nomenclatures.get_quarters(city_id: 41)
        def get_quarters(city_id: nil)
          response = post('getQuarters', body: { city_id: city_id })
          collection(response, Econt::Models::Nomenclatures::Quarter)
          # http://ee.econt.com/services/Nomenclatures/NomenclaturesService.getQuarters.json(.soap?wsdl)
        end
      end
    end
  end
end
