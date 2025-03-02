# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Profile < Resource
        include Econt::Services::Profile
        resource_type 'Profile'

        # GET /services/Profile/ProfileService.getClientProfiles.json(.soap?wsdl)
        def get_client_profiles
          get('getClientProfiles')
        end

        def create_cd_agreement
          post('createCDAgreement')
        end
      end
    end
  end
end
