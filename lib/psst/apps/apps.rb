module FastlaneCore
  module Psst
    class App < Struct.new(:app_id, :name, :platform, :prefix, :identifier, :is_wildcard)
      # Parse the server response
      def self.create(hash)
        App.new(
          hash['appIdId'],
          hash['name'],
          hash['appIdPlatform'],
          hash['prefix'],
          hash['identifier'],
          hash['isWildCard']
        )
      end

      def to_s
        [self.name, self.identifier].join(" - ")
      end

      # Example
      # app_id="572XTN75U2",
      # name="App Name",
      # platform="ios",
      # prefix="5A997XSHK2",
      # identifier="net.sunapps.7",
      # is_wildcard=false,
      # dev_push_enabled=false,
      # prod_push_enabled=false>,
    end


    class Client
      def apps
        return @apps if @apps

        response = JSON.parse(unzip(Excon.post(URL_APP_IDS, 
          headers: { 'Cookie' => "myacinfo=#{@myacinfo}" },
          body: "teamId=#{@team_id}")))

        response['appIds'].collect do |app|
          App.create(app)
        end
      end

    end
  end
end
