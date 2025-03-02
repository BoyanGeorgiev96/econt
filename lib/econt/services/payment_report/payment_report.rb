# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class PaymentReport < Resource
        include Econt::Services::PaymentReport
        resource_type 'PaymentReport'
      end
    end
  end
end
