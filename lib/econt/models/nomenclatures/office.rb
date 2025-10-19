# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class Office < Econt::Model
        field :id, type: :integer
        field :country, type: Econt::Models::Nomenclatures::Country
        field :post_code, type: :string
        field :name, type: :string
        field :name_en, type: :string
        field :region_name, type: :string
        field :region_name_en, type: :string
        field :phone_code, type: :string
        field :location, type: Econt::Models::Nomenclatures::GeoLocation
        field :express_city_deliveries, type: :boolean
        field :monday, type: :boolean
        field :tuesday, type: :boolean
        field :wednesday, type: :boolean
        field :thursday, type: :boolean
        field :friday, type: :boolean
        field :saturday, type: :boolean
        field :sunday, type: :boolean
        field :service_days, type: :integer
        field :zone_id, type: :integer
        field :zone_name, type: :string
        field :zone_name_en, type: :string
        field :serving_offices, type: Econt::Models::Nomenclatures::ServingOfficeElement
      end
    end
  end
end
