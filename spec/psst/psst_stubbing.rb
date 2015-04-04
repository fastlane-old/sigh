require 'webmock/rspec'

# Let the stubbing begin

def stub_login(fixtures)
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

def stub_provisioning(fixtures)
  stub_request(:post, "https://developerservices2.apple.com/services/QH65B2/ios/listProvisioningProfiles.action").
         with(:body => "teamId=5A997XSHAA",
              :headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developerservices2.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "list_provisioning_profiles.plist")), :headers => {})
  stub_request(:get, "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=7EKAHRBJ99").
         with(:headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developer.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "downloaded_provisioning_profile.mobileprovision")), :headers => {})
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/listProvisioningProfiles.action?teamId=5A997XSHAA").
         with(:headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developer.apple.com:443'}).
         to_return(:status => 200, :body => "", :headers => {csrf: "csrc", csrf_ts: "csrf_ts"})
end

def stub_devices(fixtures)
  stub_request(:post, "https://developerservices2.apple.com/services/QH65B2/ios/listDevices.action").
         with(:body => "teamId=5A997XSHAA",
              :headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developerservices2.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "list_devices.plist")), :headers => {})
end

def stub_certificates(fixtures)
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action?certificateStatus=0&teamId=5A997XSHAA&types=5QPB9NHCEI,R58UK2EWSO,9RQEK7MSXA,LA30L5BJEU,BKLRAVXMGM,3BQKVH9I2X,Y3B2F3TYSI,3T2ZP62QW8,E5D663CMZW,4APLUP237T").
         with(:headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developer.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "list_certificates.json")), :headers => {})
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action?certificateStatus=0&teamId=5A997XSHAA&types=5QPB9NHCEI").
         with(:headers => {'Cookie'=>'myacinfo=abcdef', 'Host'=>'developer.apple.com:443'}).
         to_return(:status => 200, :body => File.read(File.join(fixtures, "list_certificates_filtered.json")), :headers => {})
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    fixtures = "spec/psst/fixtures"

    stub_login(fixtures)
    stub_provisioning(fixtures)
    stub_devices(fixtures)
    stub_certificates(fixtures)
  end
end