# frozen_string_literal: true

module Econt
  module Models
    module Profile
      class CDPayOptions < Econt::Model
        field :num, type: :string
        field :client, type: Econt::Models::Profile::ClientProfile
        field :money_transfer, type: :boolean
        field :express, type: :boolean
        field :method, type: :string
        field :address, type: Econt::Models::Nomenclatures::Address
        field :office_code, type: :string
        field :iban, type: :string
        field :bic, type: :string
        field :bank_currency, type: :string
        field :pay_days, type: :array, of: :integer
        field :pay_weekdays, type: :array, of: :string
        field :additional_instructions, type: :string
        field :departament_num, type: :integer
      end
    end
  end
end
