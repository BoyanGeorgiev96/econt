# frozen_string_literal: true

module Econt
  module Services
    module Shipments
      class Profile < ServiceResource
        include Econt::Services::Profile

        resource_type 'Profile'

        # POST /services/Profile/ProfileService.getClientProfiles.json(.soap?wsdl)
        def get_client_profiles
          response = post('getClientProfiles')
          collection(response, Econt::Models::Profile::ProfilesResponseElement)
        end

        # POST /services/Profile/ProfileService.createCDAgreement.json(.soap?wsdl)
        def create_cd_agreement(cd_pay_options:)
          response = post('createCDAgreement', body: { cd_pay_options: cd_pay_options })
          resource(response, Econt::Models::Profile::CDPayOptions)
        end
      end
    end
  end
end
