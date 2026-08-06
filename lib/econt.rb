# frozen_string_literal: true

require_relative 'econt/version'
require_relative 'econt/util'
require_relative 'econt/error'
require_relative 'econt/client'
require_relative 'econt/camel_case_middleware'
require_relative 'econt/service_resource'
require_relative 'econt/resource_attributes'
require_relative 'econt/model'
require_relative 'econt/meta_resource'
require_relative 'econt/collection'

module Econt
  # Autoload services
  module Services
    autoload :Base, 'econt/services/base'
    autoload :Nomenclatures, 'econt/services/nomenclatures'
    autoload :Profile, 'econt/services/profile'
    autoload :Shipments, 'econt/services/shipments'
    autoload :PaymentReport, 'econt/services/payment_report'
    autoload :ThreeWayLogistics, 'econt/services/three_way_logistics'
    module Nomenclatures
      autoload :Address, 'econt/services/nomenclatures/address'
      autoload :Nomenclatures, 'econt/services/nomenclatures/nomenclatures'
    end
    module Shipments
      autoload :Label, 'econt/services/shipments/label'
      autoload :Profile, 'econt/services/profile/profile'
      autoload :Shipment, 'econt/services/shipments/shipment'
      autoload :ShipmentStatusService, 'econt/services/shipments/shipment_status_service'
      autoload :PaymentReport, 'econt/services/payment_report/payment_report'
      autoload :ThreeWayLogistics, 'econt/services/three_way_logistics/three_way_logistics'
    end
  end

  # Autoload models
  module Models
    autoload :Error, 'econt/models/error'
    autoload :HostedFile, 'econt/models/hosted_file'
    module Nomenclatures
      autoload :Address, 'econt/models/nomenclatures/address'
      autoload :City, 'econt/models/nomenclatures/city'
      autoload :Country, 'econt/models/nomenclatures/country'
      autoload :GeoLocation, 'econt/models/nomenclatures/geo_location'
      autoload :Office, 'econt/models/nomenclatures/office'
      autoload :Quarter, 'econt/models/nomenclatures/quarter'
      autoload :ServingOfficeElement, 'econt/models/nomenclatures/serving_office_element'
      autoload :Street, 'econt/models/nomenclatures/street'
      autoload :WorkingDateTime, 'econt/models/nomenclatures/working_date_time'
    end
    module Profile
      autoload :ClientProfile, 'econt/models/profile/client_profile'
      autoload :ProfilesResponseElement, 'econt/models/profile/profiles_response_element'
      autoload :CDPayOptions, 'econt/models/profile/cd_pay_options'
    end
    module Shipments
      autoload :RequestCourierStatus, 'econt/models/shipments/request_courier_status'
      autoload :ShipmentStatus, 'econt/models/shipments/shipment_status'
      autoload :ShipmentStatusService, 'econt/models/shipments/shipment_status_service'
      autoload :NextShipmentElement, 'econt/models/shipments/next_shipment_element'
      autoload :ShipmentTrackingEvent, 'econt/models/shipments/shipment_tracking_event'
      autoload :ShipmentEditionResponseElement, 'econt/models/shipments/shipment_edition_response_element'
      autoload :PreviousShipment, 'econt/models/shipments/previous_shipment'
      autoload :ReturnInstructionParams, 'econt/models/shipments/return_instruction_params'
      autoload :ShippingLabel, 'econt/models/shipments/shipping_label'
      autoload :PackElement, 'econt/models/shipments/pack_element'
      autoload :PackingListElement, 'econt/models/shipments/packing_list_element'
      autoload :CustomsListElement, 'econt/models/shipments/customs_list_element'
      autoload :CheckPossibleShipmentEditionsResultElement,
               'econt/models/shipments/check_possible_shipment_editions_result_element'
      autoload :CreateLabelResultElement, 'econt/models/shipments/create_label_result_element'
      autoload :DeleteLabelsResultElement, 'econt/models/shipments/delete_labels_result_element'
      autoload :GetMyAwbResultElement, 'econt/models/shipments/get_my_awb_result_element'
      autoload :RequestCourierStatusResultElement, 'econt/models/shipments/request_courier_status_result_element'
      autoload :ShipmentStatusResultElement, 'econt/models/shipments/shipment_status_result_element'
      autoload :UpdateLabelsResultElement, 'econt/models/shipments/update_labels_result_element'
      autoload :Instruction, 'econt/models/shipments/instruction'
    end
    module ThreeWayLogistics
      autoload :ThreeWayLogistics, 'econt/models/three_way_logistics/three_way_logistics'
    end
  end

  # Shortened model names
  Address = Models::Nomenclatures::Address
  City = Models::Nomenclatures::City
  GeoLocation = Models::Nomenclatures::GeoLocation
  Country = Models::Nomenclatures::Country
  ServingOfficeElement = Models::Nomenclatures::ServingOfficeElement
end
