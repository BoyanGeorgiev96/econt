# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class PaymentAdditionPrice < Econt::Model
        field :side, type: :string
        field :share_amount, type: :float
        field :method, type: :string
        field :other_client_number, type: :string
      end
    end
  end
end
