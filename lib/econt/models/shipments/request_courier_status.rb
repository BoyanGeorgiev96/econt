# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class RequestCourierStatus < Econt::Model
        field :id, type: :integer
        field :status, type: :string
        field :note, type: :string
        field :reject_reason, type: :string
      end
    end
  end
end
