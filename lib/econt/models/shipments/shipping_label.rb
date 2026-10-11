# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class ShippingLabel < Econt::Model
        field :shipment_number, type: :string
        field :previous_shipment_number, type: :string
        field :previous_shipment_receiver_phone, type: :string
        field :sender_client, type: Econt::Models::Profile::ClientProfile
        field :sender_agent, type: Econt::Models::Profile::ClientProfile
        field :sender_address, type: Econt::Models::Nomenclatures::Address
        field :sender_office_code, type: :string
        field :email_on_delivery, type: :string
        field :sms_on_delivery, type: :string
        field :receiver_client, type: Econt::Models::Profile::ClientProfile
        field :receiver_agent, type: Econt::Models::Profile::ClientProfile
        field :receiver_address, type: Econt::Models::Nomenclatures::Address
        field :receiver_office_code, type: :string
        field :receiver_provider_id, type: :integer
        field :receiver_bic, type: :string
        field :receiver_iban, type: :string
        field :envelope_numbers, type: :array, of: :string
        field :pack_count, type: :integer
        field :packs, type: :array, of: Econt::Models::Shipments::PackElement
        field :shipment_type, type: :string
        field :weight, type: :float
        field :size_under_60cm, type: :boolean
        field :shipment_dimensions_l, type: :float
        field :shipment_dimensions_w, type: :float
        field :shipment_dimensions_h, type: :float
        field :shipment_description, type: :string
        field :order_number, type: :string
        field :send_date, type: :date
        field :holiday_delivery_day, type: :string
        field :keep_upright, type: :boolean
        field :services, type: Econt::Models::Shipments::ShippingLabelServices
        field :instructions, type: :array, of: Econt::Models::Shipments::Instruction
        field :pay_after_accept, type: :boolean
        field :pay_after_test, type: :boolean
        field :packing_list_type, type: :string
        field :packing_list, type: :array, of: Econt::Models::Shipments::PackingListElement
        field :partial_delivery, type: :boolean
        field :payment_sender_method, type: :string
        field :payment_receiver_method, type: :string
        field :payment_receiver_amount, type: :float
        field :payment_receiver_amount_is_percent, type: :boolean
        field :payment_other_client_number, type: :string
        field :payment_other_amount, type: :float
        field :payment_other_amount_is_percent, type: :boolean
        field :mediator, type: :string
        field :payment_token, type: :string
        field :customs_list, type: :array, of: Econt::Models::Shipments::CustomsListElement
        field :customs_invoice, type: :string
        field :cargo_vehicle_options, type: Econt::Models::Shipments::CargoVehicleOptions
      end
    end
  end
end
