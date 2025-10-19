# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class ServingOfficeElement < Econt::Model
        field :office_code, type: :string
        field :serving_type, type: :string
      end
    end
  end
end
