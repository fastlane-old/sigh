module FastlaneCore
  module Psst
    class Client
      # Downloads the given provisioning profile
      def download_provisioning_profile(profile)
        url = URL_DOWNLOAD_PROVISIONING_PROFILE + profile.id

        response = Excon.get(url, headers: { "Cookie" => "myacinfo=#{@myacinfo}" } )

        path = File.join("/tmp", [profile.app.identifier, 'mobileprovision'].join('.'))
        File.write(path, response.body)
        return path
      end
    end
  end
end
