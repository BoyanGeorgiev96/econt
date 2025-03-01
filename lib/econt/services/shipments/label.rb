# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Label < Shipments
        resource_type "Label"

        # POST /services/Shipments/LabelService.createLabel.json(.soap?wsdl)
        def create_label
          response = post(resource_url("createLabel"), {})
          response.body
        end

        # POST /services/Shipments/LabelService.createLabels.json(.soap?wsdl)
        def create_labels
          response = post(resource_url("createLabels"), {})
          response.body
        end

        # POST /services/Shipments/LabelService.deleteLabel.json(.soap?wsdl)
        def delete_labels
          response = post(resource_url("deleteLabels"), {})
          response.body
        end

        # POST /services/Shipments/LabelService.updateLabel.json(.soap?wsdl)
        def update_label
          response = post(resource_url("updateLabel"), {})
          response.body
        end

        # POST /services/Shipments/LabelService.updateLabels.json(.soap?wsdl)
        def check_possible_shipment_editions
          response = post(resource_url("checkPossibleShipmentEditions"), {})
          response.body
        end

        # POST /services/Shipments/LabelService.updateLabels.json(.soap?wsdl)
        def update_labels
          response = post(resource_url("updateLabels"), {})
          response.body
        end
      end
    end
  end
end
