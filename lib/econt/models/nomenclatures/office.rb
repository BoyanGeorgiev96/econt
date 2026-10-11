# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class Office < Econt::Model
        field :id, type: :integer
        field :code, type: :string
        field :is_mps, type: :boolean
        field :is_aps, type: :boolean
        field :name, type: :string
        field :name_en, type: :string
        field :phones, type: :array, of: :string
        field :emails, type: :array, of: :string
        field :address, type: Econt::Models::Nomenclatures::Address
        field :info, type: :string
        field :currency, type: :string
        field :language, type: :string
        field :normal_business_hours_from, type: :string
        field :normal_business_hours_to, type: :string
        field :half_day_business_hours_from, type: :string
        field :half_day_business_hours_to, type: :string
        field :shipment_types, type: :array, of: :string
        field :partner_code, type: :string
        field :hub_code, type: :string
        field :hub_name, type: :string
        field :hub_name_en, type: :string
        field :is_drive, type: :boolean
      end
    end
  end
end
