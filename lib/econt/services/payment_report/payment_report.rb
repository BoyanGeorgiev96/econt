# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class PaymentReport < ServiceResource
        include Econt::Services::PaymentReport

        # POST /services/PaymentReport/PaymentReportService.PaymentReport.json(.soap?wsdl)
        def payment_report(date_to: nil, date_from: nil)
          response = post('paymentReport', body: { date_to:, date_from: })
          collection(response, Econt::Models::PaymentReport::PaymentReportRow)
        end
      end
    end
  end
end
