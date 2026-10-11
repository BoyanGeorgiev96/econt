# frozen_string_literal: true

module Econt
  module Models
    module Shipments
      class Instruction < Econt::Model
        field :id, type: :integer
        field :type, type: :string
        field :title, type: :string
        field :description, type: :string
        field :attachments, type: :array, of: Econt::Models::HostedFile
        field :voice_description, type: Econt::Models::HostedFile
        field :return_instruction_params, type: Econt::Models::Shipments::ReturnInstructionParams
        field :name, type: :string
        field :apply_to_all_parcels, type: :boolean
        field :apply_to_receivers, type: :array, of: :string
      end
    end
  end
end
