# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class AddressValidationResponse < Econt::Model
        field :address, type: Econt::Models::Nomenclatures::Address
        field :validation_status, type: :string
        field :service_info, type: Econt::Models::Nomenclatures::AddressServiceInfo

        def validation_status
          return super unless error?

          'invalid'
        end
      end
    end
  end
end
