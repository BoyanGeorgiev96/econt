# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Label < ServiceResource
        include Econt::Services::Shipments
        resource_type 'Label'

        # POST /services/Shipments/LabelService.createLabel.json(.soap?wsdl)
        def create_label
          response = post('createLabel')
          resource(response, Econt::Models::Shipments::CreateLabelResultElement)
        end

        # POST /services/Shipments/LabelService.createLabels.json(.soap?wsdl)
        def create_labels
          response = post('createLabels')
          collection(response, Econt::Models::Shipments::CreateLabelResultElement)
        end

        # POST /services/Shipments/LabelService.deleteLabels.json(.soap?wsdl)
        def delete_labels
          response = post('deleteLabels')
          collection(response, Econt::Models::Shipments::DeleteLabelsResultElement)
        end

        # POST /services/Shipments/LabelService.updateLabel.json(.soap?wsdl)
        def update_label
          response = post('updateLabel')
          resource(response, Econt::Models::Shipments::UpdateLabelsResultElement)
        end

        # POST /services/Shipments/LabelService.checkPossibleShipmentEditions.json(.soap?wsdl)
        def check_possible_shipment_editions
          response = post('checkPossibleShipmentEditions')
          collection(response, Econt::Models::Shipments::CheckPossibleShipmentEditionsResultElement)
        end

        # POST /services/Shipments/LabelService.updateLabels.json(.soap?wsdl)
        def update_labels
          response = post('updateLabels')
          collection(response, Econt::Models::Shipments::UpdateLabelsResultElement)
        end
      end
    end
  end
end
