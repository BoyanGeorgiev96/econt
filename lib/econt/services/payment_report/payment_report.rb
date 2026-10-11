# frozen_string_literal: true

module Econt
  module Services
    module PaymentReport
      class PaymentReport < ServiceResource
        include Econt::Services::PaymentReport

        # POST /services/PaymentReport/PaymentReportService.PaymentReport.json(.soap?wsdl)
        # Read payment reports for an optional date range.
        # @note Read. Does not change shipment state.
        # @param date_to [String, nil] End date in carrier format.
        # @param date_from [String, nil] Start date in carrier format.
        # @return [Econt::Collection, Econt::Models::PaymentReport::PaymentReportRow]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#payment_report Ruby usage and parameters
        # @example After configuring Econt::Client
        #   reports = Econt::Services::PaymentReport::PaymentReport.new
        #   rows = reports.payment_report(date_from: '2026-10-01', date_to: '2026-10-12')
        #   rows = rows.is_a?(Econt::Collection) ? rows.to_a : [rows]
        def payment_report(date_to: nil, date_from: nil)
          response = post('PaymentReport', body: { date_to:, date_from: })
          if response.body.is_a?(Hash) && response.body.key?('PaymentReportRows')
            return Econt::Collection.new(response.body, model: Econt::Models::PaymentReport::PaymentReportRow,
                                                        key: :payment_report_rows)
          end

          resource(response, Econt::Models::PaymentReport::PaymentReportRow)
        end
      end
    end
  end
end
