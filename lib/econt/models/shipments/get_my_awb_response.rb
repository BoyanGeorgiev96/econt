# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class GetMyAwbResponse < Econt::Model
        field :date_from, type: :date
        field :date_to, type: :date
        field :page, type: :integer
        field :total_pages, type: :integer
        field :results, type: :array, of: Econt::Models::Shipments::GetMyAwbResultElement
      end
    end
  end
end
