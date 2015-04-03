require 'psst/provisioning_profiles/download_provisioning_profile'

module FastlaneCore
  module Psst


    class ProvisioningProfile < Struct.new(:name, :type, :app_id, :app, :status, :expiration, :uuid, :id, :is_xcode_managed)
      # Parse the server response
      def self.create(hash)
        ProvisioningProfile.new(
          hash['name'],
          hash['type'],
          hash['appId']['appIdId'],
          App.create(hash['appId']), # All information related to the app
          hash['status'],
          hash['dateExpire'],
          hash['UUID'],
          hash['provisioningProfileId'],
          hash['managingApp'] == 'Xcode'
        )
      end

      def to_s
        [self.name, self.type, self.app_id].join(" - ")
      end
    end

    class Psst
      def provisioning_profiles
        return @provisioning_profiles if @provisioning_profiles

        response = unzip(Excon.post(URL_LIST_PROVISIONING_PROFILES, 
          headers: { 'Cookie' => "myacinfo=#{@myacinfo}" },
          body: "teamId=#{@team_id}"))
        profiles = Plist::parse_xml(response)['provisioningProfiles']

        @provisioning_profiles = profiles.collect do |current|
          ProvisioningProfile.create(current)
        end
      end

      # Looks for a certain provisioning profile
      def find_profile(bundle_identifier, distribution_method)
        provisioning_profiles.each do |profile|
          if profile['distributionMethod'] == distribution_method and profile['appId']['identifier'] == bundle_identifier
            return profile
          end
        end

        nil
      end
    end
  end
end
