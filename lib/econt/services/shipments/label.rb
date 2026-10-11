# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Label < ServiceResource
        include Econt::Services::Shipments

        resource_type 'Label'

        # POST /services/Shipments/LabelService.createLabel.json(.soap?wsdl)
        # Calculate, validate, or create one shipping label.
        # @note Conditional mutation. Review account permissions and cleanup before calling.
        # @param label [Hash, nil] Shipping-label payload.
        # @param request_courier_time_from [String, nil] Requested courier window start.
        # @param request_courier_time_to [String, nil] Requested courier window end.
        # @param mode [String, nil] calculate or validate are non-mutating; create and calculate_with_block have
        #   effects. Always choose explicitly.
        # @return [Econt::Models::Shipments::CreateLabelResultElement] Typed result; inspect #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#create_label Ruby usage and parameters
        # @example After configuring Econt::Client
        #   labels = Econt::Services::Shipments::Label.new
        #   quote = labels.create_label(label: label_payload, mode: 'calculate')
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
        # Calculate, validate, or create a batch of labels.
        # @note Conditional mutation. Review account permissions and cleanup before calling.
        # @param labels [Array<Hash>] Shipping-label payloads.
        # @param run_async_and_email_result_to [String, nil] Email address for asynchronous results; the returned
        #   data may differ.
        # @param mode [String, nil] Choose calculate, validate, or create explicitly.
        # @return [Econt::Collection<Econt::Models::Shipments::CreateLabelResultElement>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#create_labels Ruby usage and parameters
        # @example After configuring Econt::Client
        #   labels = Econt::Services::Shipments::Label.new
        #   quotes = labels.create_labels(labels: [label_payload], mode: 'calculate')
        def create_labels(labels: [], run_async_and_email_result_to: nil, mode: nil)
          response = post('createLabels', body: {
                            labels: labels,
                            run_async_and_email_result_to: run_async_and_email_result_to,
                            mode: mode
                          })
          collection(response, Econt::Models::Shipments::CreateLabelResultElement)
        end

        # POST /services/Shipments/LabelService.deleteLabels.json(.soap?wsdl)
        # Delete selected labels when allowed by carrier state and account permissions.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param shipment_numbers [Array<String>] Numbers of labels owned by your account.
        # @return [Econt::Collection<Econt::Models::Shipments::DeleteLabelsResultElement>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#delete_labels Ruby usage and parameters
        # @example After configuring Econt::Client
        #   labels = Econt::Services::Shipments::Label.new
        #   deleted = labels.delete_labels(shipment_numbers: [shipment_number])
        def delete_labels(shipment_numbers: [])
          response = post('deleteLabels', body: { shipment_numbers: shipment_numbers })
          collection(response, Econt::Models::Shipments::DeleteLabelsResultElement)
        end

        # POST /services/Shipments/LabelService.updateLabel.json(.soap?wsdl)
        # Update or destroy an existing label.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param label [Hash, nil] Existing label with its shipment number and requested changes.
        # @param request_courier_time_from [String, nil] Courier window start.
        # @param request_courier_time_to [String, nil] Courier window end.
        # @param destroy [Boolean, nil] Whether to destroy the label.
        # @param payment_addition_price [Hash, nil] PaymentAdditionPrice fields.
        # @param payment_instruction [Hash, nil] PaymentInstruction fields.
        # @return [Econt::Models::Shipments::UpdateLabelResponse] Typed result; inspect #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#update_label Ruby usage and parameters
        # @example After configuring Econt::Client
        #   labels = Econt::Services::Shipments::Label.new
        #   updated = labels.update_label(label: updated_label_payload, destroy: false)
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
          resource(response, Econt::Models::Shipments::UpdateLabelResponse)
        end

        # POST /services/Shipments/LabelService.checkPossibleShipmentEditions.json(.soap?wsdl)
        # Check which edits are permitted for existing shipments.
        # @note Read. Does not change shipment state.
        # @param shipment_nums [Array<Integer>] Shipment numbers in the carrier field type.
        # @return [Econt::Collection<Econt::Models::Shipments::CheckPossibleShipmentEditionsResultElement>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#check_possible_shipment_editions Ruby usage and parameters
        # @example After configuring Econt::Client
        #   labels = Econt::Services::Shipments::Label.new
        #   editions = labels.check_possible_shipment_editions(shipment_nums: [1234567890123])
        def check_possible_shipment_editions(shipment_nums: [])
          response = post('checkPossibleShipmentEditions', body: { shipment_nums: shipment_nums })
          collection(response, Econt::Models::Shipments::CheckPossibleShipmentEditionsResultElement)
        end

        # POST /services/Shipments/LabelService.updateLabels.json(.soap?wsdl)
        # Update several existing labels.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param labels [Array<Hash>] Existing labels and requested changes.
        # @return [Econt::Collection<Econt::Models::Shipments::UpdateLabelsResultElement>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#update_labels Ruby usage and parameters
        # @example After configuring Econt::Client
        #   labels = Econt::Services::Shipments::Label.new
        #   updated = labels.update_labels(labels: [updated_label_payload])
        def update_labels(labels: [])
          response = post('updateLabels', body: { labels: labels })
          collection(response, Econt::Models::Shipments::UpdateLabelsResultElement)
        end

        # POST /services/Shipments/LabelService.grouping.json(.soap?wsdl)
        # Group existing labels into a group label.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param labels [Array<Integer>] Shipment numbers to group.
        # @return [Econt::Models::Shipments::ShipmentStatus] Typed result; inspect #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#grouping Ruby usage and parameters
        # @example After configuring Econt::Client
        #   labels = Econt::Services::Shipments::Label.new
        #   group = labels.grouping(labels: [1234567890123, 1234567890124])
        def grouping(labels: [])
          response = post('grouping', body: { labels: labels })
          resource(response, Econt::Models::Shipments::ShipmentStatus, key: :label)
        end

        # POST /services/Shipments/LabelService.groupingCancelation.json(.soap?wsdl)
        # Cancel an existing group label.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param group_label [Integer, nil] Group-label shipment number.
        # @return [Econt::Models::Shipments::StatusResponse] Typed result; inspect #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#grouping_cancelation Ruby usage and parameters
        # @example After configuring Econt::Client
        #   labels = Econt::Services::Shipments::Label.new
        #   result = labels.grouping_cancelation(group_label: group_label_number)
        def grouping_cancelation(group_label: nil)
          response = post('groupingCancelation', body: { group_label: group_label })
          resource(response, Econt::Models::Shipments::StatusResponse)
        end
      end
    end
  end
end
