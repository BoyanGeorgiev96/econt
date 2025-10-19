# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class WorkingTime < Econt::Model
        field :start, type: :string
        field :end, type: :string
      end
    end
  end
end
