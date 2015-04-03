require 'excon' # HTTP Client
require 'plist' # Some responses are in the plist format
require 'pry' # TODO: Remove

require 'psst/urls'
require 'psst/helper'
require 'psst/login/login'
require 'psst/apps/apps'
require 'psst/devices/devices'
require 'psst/provisioning_profiles/provisioning_profiles'

module FastlaneCore
  module Psst
    class Client
      attr_accessor :myacinfo
      attr_accessor :team_id

      def initialize(user = nil, password = nil)
        login(user, password)
      end
    end
  end
end