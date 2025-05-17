require "spec_helper"

RSpec.describe "Error Handling", type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    # Clean up database in correct order to avoid foreign key constraints
    Emotion.delete_all
    Need.delete_all
    Want.delete_all
    User.delete_all
    
    @user = User.create!(nickname: "testuser_#{SecureRandom.hex(4)}", password: "password", password_confirmation: "password")
    post "/login", nickname: @user.nickname, password: "password"
    follow_redirect!
  end

  describe "404 error handling" do
    it "returns 404 for non-existent routes" do
      get "/nonexistent-route"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include "Page Not Found"
    end

    it "renders not found page for non-existent resources" do
      get "/need/99999"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include "Need not found"
    end

    it "renders not found page for non-existent wants" do
      get "/want/99999"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include "Want not found"
    end

    it "returns 404 for non-existent emotions" do
      get "/emotion/99999"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include "Page Not Found"
    end

    it "returns 404 for non-existent users" do
      get "/user/99999"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include "Page Not Found"
    end
  end
end
