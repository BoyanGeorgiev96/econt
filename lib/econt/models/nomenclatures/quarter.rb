# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class Quarter < Econt::Model
        field :id, type: :integer
        field :city_id, type: :integer
        field :name, type: :string
        field :name_en, type: :string
      end
    end
  end
end
