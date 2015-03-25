module FastlaneCore
  class Psst
    def list_provisioning_profiles
      response = unzip(Excon.post(URL_LIST_PROVISIONING_PROFILES, 
        headers: { 'Cookie' => "myacinfo=#{@myacinfo}" },
        body: "teamId=#{@team_id}"))
      @provisioning_profiles = Plist::parse_xml(response)['provisioningProfiles']

      profile = find_profile('net.sunapps.9', "store")


    end

    # Looks for a certain provisioning profile
    def find_profile(bundle_identifier, distribution_method)
      @provisioning_profiles.each do |profile|
        if profile['distributionMethod'] == distribution_method and profile['appId']['identifier'] == bundle_identifier
          return profile
        end
      end

      nil
    end

    # Downloads the given provisioning profile
    def download_profile(profile)
      url = URL_DOWNLOAD_PROVISIONING_PROFILE + profile['provisioningProfileId']
      response = Excon.get(url, 
        headers: { 
          "Cookie" => "myacinfo=#{@myacinfo}" # This needs to be fixed, requires more information :/ 
        body: "teamId=#{@team_id}"
      )
      downloaded = Plist::parse_xml(response)


    end
  end
end
