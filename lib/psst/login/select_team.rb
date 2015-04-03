module FastlaneCore
  module Psst
    class Psst
      # Team selection
      def select_team
        response = unzip(Excon.post(URL_LIST_TEAMS, headers: { 'Cookie' => "myacinfo=#{@myacinfo}" }))
        content = Plist::parse_xml(response)

        team_to_use = nil
        
        raise "Your account is in no teams" unless content['teams'].count > 0
        team_to_use = content['teams'].first if content['teams'].count == 1

        while not team_to_use
          # Multiple teams, user has to select
          puts "Multiple teams found, please enter the number of the team you want to use: "
          content['teams'].each_with_index do |team, i|
            puts "#{i + 1}) #{team['teamId']} #{team['name']} (#{team['type']})".green
          end

          selected = gets.strip.to_i - 1
          team_to_use = content['teams'][selected] if selected >= 0
        end

        @team_information = team_to_use
        @team_id = team_to_use['teamId']
      end
    end
  end
end