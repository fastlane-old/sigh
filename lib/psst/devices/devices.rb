module FastlaneCore
  module Psst
    class Psst
      def list_devices
        response = unzip(Excon.post(URL_LIST_DEVICES, 
          headers: { 'Cookie' => "myacinfo=#{@myacinfo}" },
          body: "teamId=#{@team_id}"))
        Plist::parse_xml(response)
      end
    end
  end
end