# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class GeoLocation < Econt::Model
        field :latitude, type: :float
        field :longitude, type: :float
        field :confidence, type: :integer
      end
    end
  end
end
