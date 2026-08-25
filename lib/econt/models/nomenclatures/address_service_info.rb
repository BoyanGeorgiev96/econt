# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class AddressServiceInfo < Econt::Model
        field :allowed_packs_courier_request, type: :boolean
        field :delivery_packs_extra_delay_days, type: :integer
        field :allowed_cargo_courier_request, type: :boolean
        field :delivery_cargo_extra_delay_days, type: :integer
        field :allowed_pallet_courier_request, type: :boolean
        field :delivery_pallet_extra_delay_days, type: :integer
      end
    end
  end
end
