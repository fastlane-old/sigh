module FastlaneCore
  module Psst
    class Client
      # Downloads the given provisioning profile
      def download_provisioning_profile(profile)
        url = URL_DOWNLOAD_PROVISIONING_PROFILE + profile.id
        response = Excon.get(url, 
          headers: { "Cookie" => "myacinfo=#{@myacinfo}" }, # This needs to be fixed, requires more information :/ 
          body: "teamId=#{@team_id}"
        )
        downloaded = Plist::parse_xml(response)
      end
    end
  end
end
