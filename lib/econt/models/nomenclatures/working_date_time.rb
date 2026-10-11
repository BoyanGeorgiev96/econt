# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class WorkingDateTime < Econt::Model
        collection_key :service_times

        field :day_type, type: :string
        field :day, type: :string
        field :start, type: :string
        field :end, type: :string
      end
    end
  end
end
