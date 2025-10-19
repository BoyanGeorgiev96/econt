# frozen_string_literal: true

require_relative 'econt/version'
require_relative 'econt/util'
require_relative 'econt/error'
require_relative 'econt/client'
require_relative 'econt/camel_case_middleware'
require_relative 'econt/service_resource'
require_relative 'econt/resource_attributes'
require_relative 'econt/model'

module Econt
  # Autoload services
  module Services
    autoload :Base, 'econt/services/base'
    autoload :Nomenclatures, 'econt/services/nomenclatures'
    module Nomenclatures
      autoload :Address, 'econt/services/nomenclatures/address'
      autoload :Nomenclatures, 'econt/services/nomenclatures/nomenclatures'
    end
  end

  # Autoload models
  module Models
    module Nomenclatures
      autoload :Address, 'econt/models/nomenclatures/address'
      autoload :City, 'econt/models/nomenclatures/city'
      autoload :GeoLocation, 'econt/models/nomenclatures/geo_location'
      autoload :Country, 'econt/models/nomenclatures/country'
      autoload :ServingOfficeElement, 'econt/models/nomenclatures/serving_office_element'
    end
  end

  # Shortened model names
  Address = Models::Nomenclatures::Address
  City = Models::Nomenclatures::City
  GeoLocation = Models::Nomenclatures::GeoLocation
  Country = Models::Nomenclatures::Country
  ServingOfficeElement = Models::Nomenclatures::ServingOfficeElement
end
