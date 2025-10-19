# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class ShippingLabelServices < Econt::Model
        field :priority_time_from, type: :string
        field :priority_time_to, type: :string
        field :delivery_receipt, type: :boolean
        field :digital_receipt, type: :boolean
        field :goods_receipt, type: :boolean
        field :two_way_shipment, type: :boolean
        field :delivery_to_floor, type: :boolean
        field :pack5, type: :integer
        field :pack6, type: :integer
        field :pack8, type: :integer
        field :pack9, type: :integer
        field :pack10, type: :integer
        field :pack12, type: :integer
        field :refrigerated_pack, type: :integer
        field :declared_value_amount, type: :float
        field :declared_value_currency, type: :string
        field :money_transfer_amount, type: :float
        field :express_money_transfer, type: :boolean
        field :cd_amount, type: :float
        field :cd_type, type: :string
        field :cd_currency, type: :string
        field :cd_pay_options_template, type: :string
        field :cd_pay_options, type: Econt::Models::Profile::CDPayOptions
        field :invoice_before_pay_cd, type: :boolean
        field :sms_notification, type: :boolean
        field :invoice_num, type: :string
      end
    end
  end
end
