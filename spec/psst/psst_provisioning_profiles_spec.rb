require 'spec_helper'
require 'pry'

require 'psst/psst'

describe "Psst", now: true do
  before do
    ENV["DELIVER_USER"] = "sigh@krausefx.com"
    ENV["DELIVER_PASSWORD"] = "so_secret"
    @client = FastlaneCore::Psst::Client.new
  end

  describe "Provisioning Profile" do
    it "successfully logged in and selected the team" do
      expect(@client.myacinfo).to eq("abcdef")
      expect(@client.team_id).to eq("5A997XSHAA")
    end

    it "downloads an existing provisioning profile" do
      path = @client.fetch_provisioning_profile('net.sunapps.9', 'store').download

      # File is correct
      expect(path).to eq("/tmp/net.sunapps.9.mobileprovision")
      xml = Plist::parse_xml(File.read(path))
      expect(xml['AppIDName']).to eq("SunApp Setup")
      expect(xml['TeamName']).to eq("SunApps GmbH")
    end

    it "properly stores the provisioning profiles as structs" do
      expect(@client.provisioning_profiles.count).to eq(58)

      profile = @client.provisioning_profiles.last
      expect(profile.client).to eq(@client)
      expect(profile.name).to eq('net.sunapps.9 Development')
      expect(profile.type).to eq('iOS Development')
      expect(profile.app_id).to eq('572SH8263D')
      expect(profile.status).to eq('Active')
      expect(profile.expiration.to_s).to eq('2016-03-05T11:46:57+00:00')
      expect(profile.uuid).to eq('34b221d4-31aa-4e55-9ea1-e5fac4f7ff8c')
      expect(profile.is_xcode_managed).to eq(false)
      expect(profile.distribution_method).to eq('limited')
    end
  end
end