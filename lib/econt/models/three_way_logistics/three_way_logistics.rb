# frozen_string_literal: true

module Econt
  module Models
    module ThreeWayLogistics
      class ThreeWayLogistics < Econt::Model
        field :requester_name, type: :string
        field :requester_phone, type: :string
        field :requester_email, type: :string
        field :requester_company_name, type: :string
        field :requester_username, type: :string
        field :supplier_company_name, type: :string
        field :supplier_contact_person, type: :string
        field :supplier_phone, type: :string
        field :supplier_city, type: :string
        field :supplier_address, type: :string
        field :supplier_date_for_visit, type: :string
        field :supplier_time_for_visit, type: :string
        field :receiver_name, type: :string
        field :receiver_company_name, type: :string
        field :receiver_phone, type: :string
        field :receiver_email, type: :string
        field :description_shipment_description, type: :string
        field :description_shipment_count, type: :string
        field :description_shipment_weight, type: :string
        field :description_additional_instructions, type: :string
        field :description_payment_sum_to_supplier, type: :string
        field :delivery_details_city, type: :string
        field :delivery_details_address, type: :string
        field :delivery_details_office, type: :string
        field :dc, type: :string
        field :dccp, type: :string
        field :email_on_delivery, type: :string
        field :invoice_before_pay, type: :string
        field :preview, type: :string
        field :test, type: :string
        field :payment_delivery_and_return_by_me, type: :string
        field :payment_return_by_me, type: :string
        field :payment_delivery_by_requester, type: :string
        field :payment_delivery_by_receiver, type: :string
        field :oc_sum, type: :string
        field :cd_sum, type: :string
        field :priority_delivery_time_before, type: :string
        field :priority_delivery_time_after, type: :string
        field :priority_delivery_time_in, type: :string
      end
    end
  end
end
