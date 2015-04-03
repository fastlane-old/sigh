module FastlaneCore
  module Psst
    class App < Struct.new(:app_id, :name, :platform, :prefix, :identifier, :is_wildcard, :dev_push_enabled, :prod_push_enabled)
      # Parse the server response
      def self.create(hash)
        App.new(
          hash['appIdId'],
          hash['name'],
          hash['appIdPlatform'],
          hash['prefix'],
          hash['identifier'],
          hash['isWildCard'],
          hash['isDevPushEnabled'],
          hash['isProdPushEnabled']
        )
      end

      def to_s
        [self.name, self.identifier].join(" - ")
      end
    end


    class Psst

    end
  end
end
