# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Shipment < ServiceResource
        include Econt::Services::Shipments

        resource_type 'Shipment'

        # services/Shipments/ShipmentService.requestCourier.json(.soap?wsdl)
        # Book a courier collection; pass the documented request fields as keywords.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param attributes [Hash] Courier payload as keywords: request_time_from, request_time_to, shipment_type,
        #   shipment_pack_count, shipment_weight, sender_client, sender_agent, sender_address, attach_shipments,
        #   pack12, cargo_vehicle_options.
        # @return [Econt::Models::Shipments::RequestCourierResponse] Typed result; inspect #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#request_courier Ruby usage and parameters
        # @example After configuring Econt::Client
        #   shipments = Econt::Services::Shipments::Shipment.new
        #   booking = shipments.request_courier(**courier_payload)
        def request_courier(**attributes)
          response = post('requestCourier', body: attributes)
          resource(response, Econt::Models::Shipments::RequestCourierResponse)
        end

        # services/Shipments/ShipmentService.getShipmentStatuses.json(.soap?wsdl)
        # Read shipment status, tracking events, and label information.
        # @note Read. Does not change shipment state.
        # @param shipment_numbers [Array<String>] Shipment numbers to query.
        # @return [Econt::Collection<Econt::Models::Shipments::ShipmentStatusResultElement>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_shipment_statuses Ruby usage and parameters
        # @example After configuring Econt::Client
        #   shipments = Econt::Services::Shipments::Shipment.new
        #   statuses = shipments.get_shipment_statuses(shipment_numbers: [shipment_number])
        def get_shipment_statuses(shipment_numbers: [])
          response = post('getShipmentStatuses', body: { shipment_numbers: shipment_numbers })
          collection(response, Econt::Models::Shipments::ShipmentStatusResultElement)
        end

        # services/Shipments/ShipmentService.getRequestCourierStatus.json(.soap?wsdl)
        # Read the status of courier collection requests.
        # @note Read. Does not change shipment state.
        # @param request_courier_ids [Array<Integer>] Courier request identifiers.
        # @return [Econt::Collection<Econt::Models::Shipments::RequestCourierStatusResultElement>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_request_courier_status Ruby usage and parameters
        # @example After configuring Econt::Client
        #   shipments = Econt::Services::Shipments::Shipment.new
        #   statuses = shipments.get_request_courier_status(request_courier_ids: [courier_request_id])
        def get_request_courier_status(request_courier_ids: [])
          response = post('getRequestCourierStatus', body: { request_courier_ids: request_courier_ids })
          collection(response, Econt::Models::Shipments::RequestCourierStatusResultElement)
        end

        # services/Shipments/ShipmentService.getMyAWB.json(.soap?wsdl)
        # List account waybills using optional date, page, and side filters.
        # @note Read. Does not change shipment state.
        # @param date_from [String, nil] Start date in carrier format.
        # @param date_to [String, nil] End date in carrier format.
        # @param page [Integer, nil] Requested page.
        # @param side [String, nil] Carrier side filter; see getMyAWB documentation for allowed values.
        # @return [Econt::Models::Shipments::GetMyAwbResponse] Typed result; inspect #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_my_awb Ruby usage and parameters
        # @example After configuring Econt::Client
        #   shipments = Econt::Services::Shipments::Shipment.new
        #   waybills = shipments.get_my_awb(date_from: '2026-10-01', date_to: '2026-10-12', page: 1)
        def get_my_awb(date_from: nil, date_to: nil, page: nil, side: nil)
          body = { date_from: date_from, date_to: date_to, page: page, side: side }.compact
          response = post('getMyAWB', body: body)
          resource(response, Econt::Models::Shipments::GetMyAwbResponse)
        end

        # services/Shipments/ShipmentService.setITUCode.json(.soap?wsdl)
        # Assign ITU transport metadata to a waybill.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param awb_barcode [String] Waybill barcode.
        # @param truck_reg_num [String] Truck registration number.
        # @param itu_code [String] ITU code; sent with the carrier spelling ITU_code.
        # @return [Faraday::Response] Raw response; inspect #body.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#set_itu_code Ruby usage and parameters
        # @example After configuring Econt::Client
        #   shipments = Econt::Services::Shipments::Shipment.new
        #   response = shipments.set_itu_code(
        #     awb_barcode: shipment_number, truck_reg_num: truck_registration, itu_code: itu_code
        #   )
        #   response.body
        def set_itu_code(awb_barcode:, truck_reg_num:, itu_code:)
          post_raw('setITUCode', body: {
                     'awbBarcode' => awb_barcode,
                     'truckRegNum' => truck_reg_num,
                     'ITU_code' => itu_code
                   })
        end
      end
    end
  end
end
