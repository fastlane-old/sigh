require 'psst/provisioning_profiles/download_provisioning_profile'

module FastlaneCore
  module Psst

    class ProvisioningProfile < Struct.new(:client, :name, :type, :app_id, :app, :status, :expiration, :uuid, :id, :is_xcode_managed, :distribution_method)
      # Parse the server response
      def self.create(client, hash)
        ProvisioningProfile.new(
          client,
          hash['name'],
          hash['type'],
          hash['appId']['appIdId'],
          App.create(hash['appId']), # All information related to the app
          hash['status'],
          hash['dateExpire'],
          hash['UUID'],
          hash['provisioningProfileId'],
          hash['managingApp'] == 'Xcode',
          hash['distributionMethod']
        )
      end

      # Downloads the given provisioning profile
      def download
        client.download_provisioning_profile(self)
      end

      def to_s
        [self.name, self.type, self.app_id].join(" - ")
      end
    end



    class Client
      def provisioning_profiles
        return @provisioning_profiles if @provisioning_profiles

        response = unzip(Excon.post(URL_LIST_PROVISIONING_PROFILES, 
          headers: { 'Cookie' => "myacinfo=#{@myacinfo}" },
          body: "teamId=#{@team_id}"))
        profiles = Plist::parse_xml(response)['provisioningProfiles']

        @provisioning_profiles = profiles.collect do |current|
          ProvisioningProfile.create(self, current)
        end
      end

      # Looks for a certain provisioning profile
      # distribution_method valid values: [store, limited]
      def find_provisioning_profile(bundle_identifier, distribution_method)
        provisioning_profiles.each do |profile|
          if profile.app.identifier == bundle_identifier and profile.distribution_method == distribution_method
            return profile
          end
        end

        nil
      end
    end
  end
end
