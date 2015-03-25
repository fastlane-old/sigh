module FastlaneCore
  class Psst
    def list_devices
      response = unzip(Excon.post(URL_LIST_DEVICES, 
        headers: { 'Cookie' => "myacinfo=#{@myacinfo}" },
        body: "teamId=#{@team_id}"))
      unzip(resp)
    end
  end
end