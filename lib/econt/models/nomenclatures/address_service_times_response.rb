# frozen_string_literal: true

module Econt
  module Models
    module Nomenclatures
      class AddressServiceTimesResponse < Econt::Model
        field :service_office, type: Econt::Models::Nomenclatures::Office
        field :service_office_latitude, type: :float
        field :service_office_longitude, type: :float
        field :service_office_clients_work_times, type: :array, of: Econt::Models::Nomenclatures::WorkingTime
        field :service_office_courier_work_times, type: :array, of: Econt::Models::Nomenclatures::WorkingTime
        field :service_office_time, type: Econt::Models::Nomenclatures::WorkingDateTime
        field :service_office_next30days_work_time,
              type: :array,
              of: Econt::Models::Nomenclatures::WorkingDateTime
      end
    end
  end
end
