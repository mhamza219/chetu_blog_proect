require 'rails_helper'

RSpec.describe "Users::Locations", type: :request do
  include Devise::Test::IntegrationHelpers
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe "POST /update_location" do
    it "updates latitude and longitude for the logged-in user" do
      post update_user_location_path, params: { latitude: 37.7749, longitude: -122.4194 }, as: :json
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
      
      user.reload
      expect(user.latitude).to eq(37.7749)
      expect(user.longitude).to eq(-122.4194)
      expect(user.formatted_location).to be_present
    end
  end
end
