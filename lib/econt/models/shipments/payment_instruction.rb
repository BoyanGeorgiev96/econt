# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class PaymentInstruction < Econt::Model
        field :method, type: :string
      end
    end
  end
end
