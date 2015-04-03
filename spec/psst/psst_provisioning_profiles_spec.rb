require 'spec_helper'

describe "Psst", now: true do
  describe "Provisioning Profile" do
    before do
      @client = FastlaneCore::Psst::Client.new
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
      expect(@client.provisioning_profiles.count).to eq(33) # ignore the Xcode generated profiles

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

    it "raises an exception when passing an invalid distribution type" do
      expect {
        @client.fetch_provisioning_profile('net.sunapps.999', 'invalid_parameter')
      }.to raise_exception("Invalid distribution_method")
    end

    it "creates a new provisioning profile if it doesn't exist" do
      # path = @client.fetch_provisioning_profile('net.sunapps.106', 'limited').download
    end

    it "repairs a provisioning profile if the old one is broken" do

    end
  end
end