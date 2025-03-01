# frozen_string_literal: true

module Econt
  module Services
    class Nomenclatures < Resource
      autoload :Nomenclatures, "econt/services/nomenclatures/nomenclatures"
      autoload :Address, "econt/services/nomenclatures/address"

      def self.resource_url
        "Nomenclatures"
      end
    end
  end
end
