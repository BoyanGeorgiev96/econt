# frozen_string_literal: true

module Econt
  module Models
    module PaymentReport
      class PaymentReportRow < Econt::Model
        field :num, type: :integer
        field :type, type: :string
        field :pay_type, type: :string
        field :pay_date, type: :string
        field :amount, type: :float
        field :currency, type: :string
        field :created_time, type: :string
      end
    end
  end
end
