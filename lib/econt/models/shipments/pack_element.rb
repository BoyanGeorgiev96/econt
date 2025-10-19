# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class PackElement < Econt::Model
        field :width, type: :float
        field :height, type: :float
        field :length, type: :float
        field :weight, type: :float
      end
    end
  end
end
