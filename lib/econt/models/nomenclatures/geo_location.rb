# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class GeoLocation < Econt::Model
        field :latitude, type: :double
        field :longitude, type: :double
        field :confidence, type: :integer
      end
    end
  end
end
