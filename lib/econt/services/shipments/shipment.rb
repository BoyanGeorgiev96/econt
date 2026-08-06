# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Shipment < ServiceResource
        include Econt::Services::Shipments
        resource_type 'Shipment'

        # services/Shipments/ShipmentService.requestCourier.json(.soap?wsdl)
        def request_courier
          post('requestCourier')
        end

        # services/Shipments/ShipmentService.getShipmentStatuses.json(.soap?wsdl)
        def get_shipment_statuses
          response = get('getShipmentStatuses')
          collection(response, Econt::Models::Shipments::ShipmentStatusResultElement)
        end

        # services/Shipments/ShipmentService.getRequestCourierStatus.json(.soap?wsdl)
        def get_request_courier_status
          response = get('getRequestCourierStatus')
          collection(response, Econt::Models::Shipments::RequestCourierStatusResultElement)
        end

        # services/Shipments/ShipmentService.getMyAWB.json(.soap?wsdl)
        def get_my_awb
          response = get('getMyAWB')
          collection(response, Econt::Models::Shipments::GetMyAwbResultElement)
        end

        # services/Shipments/ShipmentService.setITUCode.json(.soap?wsdl)
        def set_itu_code(awb_barcode:, truck_reg_num:, itu_code:)
          post('setITUCode', body: { awb_barcode:, truck_reg_num:, itu_code: })
        end
      end
    end
  end
end
