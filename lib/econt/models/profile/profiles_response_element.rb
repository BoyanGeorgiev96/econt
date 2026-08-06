# frozen_string_literal: true

module Econt
  module Models
    module Profile
      class ProfilesResponseElement < Econt::Model
        collection_key :profiles

        field :client, type: Econt::Models::Profile::ClientProfile
        field :addresses, type: :array, of: Econt::Models::Nomenclatures::Address
        field :cd_pay_options, type: :array, of: Econt::Models::Profile::CDPayOptions
        field :instruction_templates, type: :array, of: Econt::Models::Shipments::Instruction
      end
    end
  end
end
