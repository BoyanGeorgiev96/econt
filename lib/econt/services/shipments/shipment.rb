# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Shipment < Resource
        include Econt::Services::Shipments
        resource_type 'Shipment'

        # services/Shipments/ShipmentService.requestCourier.json(.soap?wsdl)
        def request_courier
          post('requestCourier')
        end

        # services/Shipments/ShipmentService.createShipment.json(.soap?wsdl)
        def get_shipment_statuses
          get('getShipmentStatuses')
        end

        # services/Shipments/ShipmentService.getShipmentStatuses.json(.soap?wsdl)
        def get_request_courier_status
          get('getRequestCourierStatus')
        end

        # services/Shipments/ShipmentService.getMyAWB.json(.soap?wsdl)
        def get_my_awb
          get('getMyAWB')
        end

        # services/Shipments/ShipmentService.setITUCode.json(.soap?wsdl)
        def set_itu_code
          post('setITUCode')
        end
      end
    end
  end
end
