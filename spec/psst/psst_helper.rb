require 'webmock/rspec'

# Let the stubbing begin

def stub_login
  fixtures = "spec/psst/fixtures"

  stub_request(:get, "https://developer.apple.com/devcenter/ios/index.action").
         with(:headers => {'Host'=>'developer.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "landing_page.html")), :headers => {})
  stub_request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate").
         with(:body => {"accountPassword"=>"so_secret", "appIdKey"=>"2089349823abbababa98239839", "appleId"=>"sigh@krausefx.com"},
              :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'idmsa.apple.com:443'}).
         to_return(:status => 200, :body => "", :headers => {'Set-Cookie' => "myacinfo=abcdef;"}) 
  # List the teams
  stub_request(:post, "https://developerservices2.apple.com/services/QH65B2/listTeams.action").
         with(:headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developerservices2.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "list_teams.plist")), :headers => {})
end

def stub_provisioning
  fixtures = "spec/psst/fixtures"

  stub_request(:post, "https://developerservices2.apple.com/services/QH65B2/ios/listProvisioningProfiles.action").
         with(:body => "teamId=5A997XSHAA",
              :headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developerservices2.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "list_provisioning_profiles.plist")), :headers => {})
  stub_request(:get, "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=7EKAHRBJ99").
         with(:headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developer.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "downloaded_provisioning_profile.mobileprovision")), :headers => {})
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    stub_login
    stub_provisioning
  end
end