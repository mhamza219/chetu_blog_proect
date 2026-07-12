require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  describe "POST /users" do
    let(:valid_attributes) do
      {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123",
        display_name: "Test User",
        phone_number: "1234567890",
        address: "123 Main Street",
        gender: "Male"
      }
    end

    it "creates a new user with custom attributes" do
      expect {
        post user_registration_path, params: { user: valid_attributes }
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.display_name).to eq("Test User")
      expect(user.phone_number).to eq("1234567890")
      expect(user.address).to eq("123 Main Street")
      expect(user.gender).to eq("Male")
    end
  end

  describe "PUT /users" do
    include Devise::Test::IntegrationHelpers

    let(:user) { create(:user) }
    let(:update_attributes) do
      {
        display_name: "Updated Name",
        phone_number: "0987654321",
        address: "456 Side Street",
        gender: "Female",
        current_password: user.password
      }
    end

    before do
      sign_in user
    end

    it "updates the user custom attributes" do
      put user_registration_path, params: { user: update_attributes }
      user.reload

      expect(user.display_name).to eq("Updated Name")
      expect(user.phone_number).to eq("0987654321")
      expect(user.address).to eq("456 Side Street")
      expect(user.gender).to eq("Female")
    end
  end
end
