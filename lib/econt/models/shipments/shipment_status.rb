# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class ShipmentStatus < Econt::Model
        field :shipment_number, type: :string
        field :storage_office_name, type: :string
        field :storage_person_name, type: :string
        field :created_time, type: :date
        field :send_time, type: :date
        field :delivery_time, type: :date
        field :shipment_type, type: :string
        field :pack_count, type: :integer
        field :shipment_description, type: :string
        field :weight, type: :float
        field :sender_delivery_type, type: :string
        field :sender_client, type: Econt::Models::Profile::ClientProfile
        field :sender_agent, type: Econt::Models::Profile::ClientProfile
        field :sender_office_code, type: :string
        field :sender_address, type: Econt::Models::Nomenclatures::Address
        field :receiver_delivery_type, type: :string
        field :receiver_client, type: Econt::Models::Profile::ClientProfile
        field :receiver_agent, type: Econt::Models::Profile::ClientProfile
        field :receiver_office_code, type: :string
        field :receiver_address, type: Econt::Models::Nomenclatures::Address
        field :hub_code, type: :string
        field :hub_name, type: :string
        field :hub_name_en, type: :string
        field :cd_collected_amount, type: :float
        field :cd_collected_currency, type: :string
        field :cd_collected_time, type: :date
        field :cd_paid_amount, type: :float
        field :cd_paid_currency, type: :string
        field :cd_paid_time, type: :date
        field :total_price, type: :float
        field :currency, type: :string
        field :discount_percent, type: :float
        field :discount_amount, type: :float
        field :discount_description, type: :string
        field :sender_due_amount, type: :float
        field :receiver_due_amount, type: :float
        field :other_due_amount, type: :float
        field :delivery_attempt_count, type: :integer
        field :previous_shipment_number, type: :string
        field :services, type: :array, of: Econt::Models::Shipments::ShipmentStatusService
        field :last_processed_instruction, type: :string
        field :next_shipments, type: :array, of: Econt::Models::Shipments::NextShipmentElement
        field :tracking_events, type: :array, of: Econt::Models::Shipments::ShipmentTrackingEvent
        field :pdf_url, type: :string
        field :expected_delivery_date, type: :date
        field :return_shipment_url, type: :string
        field :reject_original_parcel_pay_side, type: :string
        field :reject_return_parcel_pay_side, type: :string
        field :shipment_edition, type: Econt::Models::Shipments::ShipmentEditionResponseElement
        field :previous_shipment, type: Econt::Models::Shipments::PreviousShipment
        field :warnings, type: :string
        field :short_delivery_status, type: :string
        field :short_delivery_status_en, type: :string
        field :routing_code, type: :string
      end
    end
  end
end
