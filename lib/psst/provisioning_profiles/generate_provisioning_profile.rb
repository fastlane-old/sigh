module FastlaneCore
  module Psst
    class Client
      # Generates the given provisioning profile
      def generate_provisioning_profile!(profile)
        url = URL_CREATE_PROVISIONING_PROFILE + @team_id

        response = Excon.post(url, 
          headers: { 
            "Cookie" => "myacinfo=#{@myacinfo}",
            "Content-Type" => "application/x-www-form-urlencoded",
            csrf: csrf,
            csrf_ts: csrf_ts
          },
          body: URI.encode_www_form(
            appIdId: profile.app.app_id,
            distributionType: 'adhoc', # TODO
            certificateIds: '[XC5PH8D47H]', # TODO
            deviceIds: '[XJXGVS46MW]', # TODO: All devices
            provisioningProfileName: profile.name,
            returnFullObjects: false
          )
        )

        handle_create_error(response)

        result = JSON.parse(unzip(response))

        if result['resultCode'] == 0
          Helper.log.info "Successfully generated new provisioning profile: '#{profile.name}'"
          return true
        end
        return false
      end

      def handle_create_error(response)
        if response.body.include?"Multiple profiles found with the name"
          raise response.body.gsub("&#x27;", '"').red
        end
      end

      def csrf
        fetch_csrf_values
        @csrf
      end

      def csrf_ts
        fetch_csrf_values
        @csrf_ts
      end

      private
        # Fetches the csrf and csrf_ts (timestamp) and stores them in @csrf and @csrf_ts
        def fetch_csrf_values
          return if @csrf and @csrf_ts

          url = URL_GET_CSRF_VALUES + @team_id
          response = Excon.post(url, headers: {
            "Cookie" => "myacinfo=#{@myacinfo}"
          })

          @csrf = response.headers['csrf']
          @csrf_ts = response.headers['csrf_ts']
        end
    end
  end
end
