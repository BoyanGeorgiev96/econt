# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class PackingListElement < Econt::Model
        field :inventory_num, type: :string
        field :description, type: :string
        field :weight, type: :float
        field :count, type: :integer
        field :price, type: :float
        field :file, type: Econt::Models::HostedFile
        field :alternative_department, type: :string
      end
    end
  end
end
