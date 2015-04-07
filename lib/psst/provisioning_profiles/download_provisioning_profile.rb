module FastlaneCore
  module Psst
    class Client
      # Downloads the given provisioning profile
      def download_provisioning_profile(profile)
        raise "Profile '#{profile}' is broken and does not contain an ID".red unless profile.id
        
        url = URL_DOWNLOAD_PROVISIONING_PROFILE + profile.id

        response = Excon.get(url, headers: { "Cookie" => "myacinfo=#{@myacinfo}" } )

        file_name = [profile.app.identifier, profile.distribution_method, 'mobileprovision'].join('.')
        path = File.join("/tmp", file_name)
        File.write(path, response.body)
        return path
      end
    end
  end
end
