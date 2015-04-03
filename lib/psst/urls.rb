module FastlaneCore
  module Psst
    class Client
      ######## GENERAL ########
      PROTOCOL_VERSION = "QH65B2"

      ######## LOGIN ########
      # URL that contains the "Sign In" button, which is required to log in successfully
      URL_LOGIN_LANDING_PAGE = "https://developer.apple.com/devcenter/ios/index.action"

      # Used to send the username + password to generate a valid session
      URL_AUTHENTICATE = "https://idmsa.apple.com/IDMSWebAuth/authenticate"

      ######## Select Team ########
      # A list of all teams for the given Apple ID
      URL_LIST_TEAMS = "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/listTeams.action"

      ######## Provisioning Profiles ########
      # Lists all available provisioning profiles
      URL_LIST_PROVISIONING_PROFILES = "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/ios/listProvisioningProfiles.action"

      URL_DOWNLOAD_PROVISIONING_PROFILE = "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId="

      URL_CREATE_PROVISIONING_PROFILE = "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/account/ios/profile/createProvisioningProfile.action?teamId="

      URL_GET_CSRF_VALUES = "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/account/ios/profile/listProvisioningProfiles.action?teamId="

      ######## Device Management ########
      # List all devices enabled for this Apple ID
      URL_LIST_DEVICES = "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/ios/listDevices.action"
    end
  end
end