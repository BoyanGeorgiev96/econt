# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class Country < Econt::Model
        field :id, type: :integer
        field :code2, type: :string
        field :code3, type: :string
        field :name, type: :string
        field :name_en, type: :string
        field :isEU, type: :boolean
      end
    end
  end
end
