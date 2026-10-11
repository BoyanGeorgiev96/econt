# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class ReturnInstructionParams < Econt::Model
        field :return_parcel_destination, type: :string
        field :return_parcel_is_document, type: :boolean
        field :return_parcel_is_empty_pallet, type: :boolean
        field :empty_pallet_euro, type: :integer
        field :empty_pallet80, type: :integer
        field :empty_pallet100, type: :integer
        field :empty_pallet120, type: :integer

        alias empty_pallet_80 empty_pallet80
        alias empty_pallet_80= empty_pallet80=
        alias empty_pallet_100 empty_pallet100
        alias empty_pallet_100= empty_pallet100=
        alias empty_pallet_120 empty_pallet120
        alias empty_pallet_120= empty_pallet120=
        field :days_until_return, type: :integer
        field :return_parcel_payment_side, type: :string
        field :return_parcel_receiver_client, type: Econt::Models::Profile::ClientProfile
        field :return_parcel_receiver_agent, type: Econt::Models::Profile::ClientProfile
        field :return_parcel_receiver_office_code, type: :string
        field :return_parcel_receiver_address, type: Econt::Models::Nomenclatures::Address
        field :print_return_parcel, type: :boolean
        field :reject_action, type: :string
        field :reject_instruction, type: :string
        field :reject_contact, type: :string
        field :reject_return_client, type: Econt::Models::Profile::ClientProfile
        field :reject_return_agent, type: Econt::Models::Profile::ClientProfile
        field :reject_return_office_code, type: :string
        field :reject_return_address, type: Econt::Models::Nomenclatures::Address
        field :reject_original_parcel_pay_side, type: :string
        field :reject_return_parcel_pay_side, type: :string
        field :signature_documents, type: :boolean
        field :signature_pen_color, type: :string
        field :signature_count, type: :integer
        field :signature_page_numbers, type: :string
        field :signature_other_instructions, type: :string
        field :execute_if_rejected_without_review, type: :boolean
        field :use_return_address_for_instruction, type: :boolean
        field :execute_if_not_taken, type: :integer
      end
    end
  end
end
