# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class CustomsListElement < Econt::Model
        field :cn, type: :string
        field :description, type: :string
        field :sum, type: :float
        field :currency, type: :string
      end
    end
  end
end
