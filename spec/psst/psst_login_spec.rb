require 'spec_helper'

describe "Psst", now: true do
  describe "Login" do
    before do
      @client = FastlaneCore::Psst::Client.new
    end
    
    it "successfully logged in and selected the team" do
      expect(@client.myacinfo).to eq("abcdef")
      expect(@client.team_id).to eq("5A997XSHAA")
    end
  end
end