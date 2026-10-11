# frozen_string_literal: true

module Econt
  module Services
    module Profile
      class Profile < ServiceResource
        include Econt::Services::Profile

        resource_type 'Profile'

        # POST /services/Profile/ProfileService.getClientProfiles.json(.soap?wsdl)
        # Read account client profiles and payment settings.
        # @note Read. Does not change shipment state.
        # @return [Econt::Collection<Econt::Models::Profile::ProfilesResponseElement>]
        #   Check #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#get_client_profiles Ruby usage and parameters
        # @example After configuring Econt::Client
        #   profiles = Econt::Services::Profile::Profile.new
        #   clients = profiles.get_client_profiles
        def get_client_profiles
          response = post('getClientProfiles')
          collection(response, Econt::Models::Profile::ProfilesResponseElement)
        end

        # POST /services/Profile/ProfileService.createCDAgreement.json(.soap?wsdl)
        # Create a cash-on-delivery payment agreement.
        # @note Mutation. Review account permissions and cleanup before calling.
        # @param cd_pay_options [Hash] CDPayOptions payload; account eligibility is carrier-controlled.
        # @return [Econt::Models::Profile::CDPayOptions] Typed result; inspect #error? before using data.
        # @raise [Econt::Error] On HTTP failure.
        # @raise [Econt::TransportError] On connection, timeout, or TLS failure; inspect its subclass.
        # @see file:docs/API.md#create_cd_agreement Ruby usage and parameters
        # @example After configuring Econt::Client
        #   profiles = Econt::Services::Profile::Profile.new
        #   agreement = profiles.create_cd_agreement(cd_pay_options: cd_pay_options_payload)
        def create_cd_agreement(cd_pay_options:)
          response = post('createCDAgreement', body: { cd_pay_options: cd_pay_options })
          resource(response, Econt::Models::Profile::CDPayOptions, key: :cd_pay_options)
        end
      end
    end
  end
end
