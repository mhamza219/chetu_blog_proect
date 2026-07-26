require 'rails_helper'

RSpec.describe "DistanceCalculator", type: :request do
  include Devise::Test::IntegrationHelpers
  let(:user) { FactoryBot.create(:user, latitude: 37.7749, longitude: -122.4194) }

  describe "GET /distance_calculator" do
    it "renders the distance calculator page successfully" do
      get distance_calculator_path
      expect(response).to have_http_status(:success)
    end

    it "pre-fills user coordinates when signed in" do
      sign_in user
      get distance_calculator_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("37.7749")
    end
  end

  describe "POST /distance_calculator/calculate" do
    it "calculates distance between two coordinate sets" do
      post calculate_distance_path, params: {
        origin_lat: 37.7749,
        origin_lng: -122.4194,
        dest_lat: 34.0522,
        dest_lng: -118.2437
      }, as: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
      expect(json["distance_km"]).to be_a(Numeric)
      expect(json["distance_miles"]).to be_a(Numeric)
    end
  end

  describe "GET /distance_calculator/search" do
    it "returns search results for a location query" do
      get search_distance_location_path, params: { q: "San Francisco" }, as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
    end
  end
end
