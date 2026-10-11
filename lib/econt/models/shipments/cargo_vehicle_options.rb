# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class CargoVehicleOptions < Econt::Model
        field :sender_address_truck_access, type: :boolean
        field :receiver_address_truck_access, type: :boolean
        field :sender_address_lifting_vehicle_required, type: :boolean
        field :receiver_address_lifting_vehicle_required, type: :boolean
        field :sender_address_tail_lift_truck_required, type: :boolean
        field :receiver_address_tail_lift_truck_required, type: :boolean
      end
    end
  end
end
