# frozen_string_literal: true

module Econt
  module Models
    module Profile
      class ClientProfile < Econt::Model
        field :id, type: :integer
        field :name, type: :string
        field :name_en, type: :string
        field :phones, type: :string
        field :email, type: :string
        field :skype_accounts, type: :string
        field :client_number, type: :string
        field :client_number_en, type: :string
        field :juridical_entity, type: :boolean
        field :personal_id_type, type: :string
        field :personal_id_number, type: :string
        field :company_type, type: :string
        field :ein, type: :string
        field :dds_ein_prefix, type: :string
        field :dds_ein, type: :string
        field :registration_address, type: :string
        field :mol_name, type: :string
        field :mol_egn, type: :string
        field :mol_id_num, type: :string
      end
    end
  end
end
