# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Label < ServiceResource
        include Econt::Services::Shipments
        resource_type 'Label'

        # POST /services/Shipments/LabelService.createLabel.json(.soap?wsdl)
        def create_label(label: nil, request_courier_time_from: nil, request_courier_time_to: nil, mode: nil)
          response = post('createLabel', body: {
                            label: label,
                            request_courier_time_from: request_courier_time_from,
                            request_courier_time_to: request_courier_time_to,
                            mode: mode
                          })
          resource(response, Econt::Models::Shipments::CreateLabelResultElement)
        end

        # POST /services/Shipments/LabelService.createLabels.json(.soap?wsdl)
        def create_labels(labels: [], run_async_and_email_result_to: nil, mode: nil)
          response = post('createLabels', body: {
                            labels: labels,
                            run_async_and_email_result_to: run_async_and_email_result_to,
                            mode: mode
                          })
          collection(response, Econt::Models::Shipments::CreateLabelResultElement)
        end

        # POST /services/Shipments/LabelService.deleteLabels.json(.soap?wsdl)
        def delete_labels(shipment_numbers: [])
          response = post('deleteLabels', body: { shipment_numbers: shipment_numbers })
          collection(response, Econt::Models::Shipments::DeleteLabelsResultElement)
        end

        # POST /services/Shipments/LabelService.updateLabel.json(.soap?wsdl)
        def update_label(label: nil, request_courier_time_from: nil, request_courier_time_to: nil, destroy: nil,
                         payment_addition_price: nil, payment_instruction: nil)
          response = post('updateLabel', body: {
                            label: label,
                            request_courier_time_from: request_courier_time_from,
                            request_courier_time_to: request_courier_time_to,
                            destroy: destroy,
                            payment_addition_price: payment_addition_price,
                            payment_instruction: payment_instruction
                          })
          resource(response, Econt::Models::Shipments::UpdateLabelsResultElement)
        end

        # POST /services/Shipments/LabelService.checkPossibleShipmentEditions.json(.soap?wsdl)
        def check_possible_shipment_editions(shipment_nums: [])
          response = post('checkPossibleShipmentEditions', body: { shipment_nums: shipment_nums })
          collection(response, Econt::Models::Shipments::CheckPossibleShipmentEditionsResultElement)
        end

        # POST /services/Shipments/LabelService.updateLabels.json(.soap?wsdl)
        def update_labels(labels: [])
          response = post('updateLabels', body: { labels: labels })
          collection(response, Econt::Models::Shipments::UpdateLabelsResultElement)
        end

        # POST /services/Shipments/LabelService.grouping.json(.soap?wsdl)
        def grouping(labels: [])
          response = post('grouping', body: { labels: labels })
          resource(response, Econt::Models::Shipments::ShipmentStatus, key: :label)
        end

        # POST /services/Shipments/LabelService.groupingCancelation.json(.soap?wsdl)
        def grouping_cancelation(group_label: nil)
          post('groupingCancelation', body: { group_label: group_label })
        end
      end
    end
  end
end
