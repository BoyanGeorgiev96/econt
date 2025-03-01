# frozen_string_literal: true

module Econt
  module Services
    class Profile < Resource
      autoload :Profile, "econt/services/profile/profile"
      def self.resource_url
        "Profile"
      end
    end
  end
end
