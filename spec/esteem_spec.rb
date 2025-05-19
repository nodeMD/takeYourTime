require "spec_helper"

RSpec.describe "Esteems Management", type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    Need.delete_all
    Emotion.delete_all
    User.delete_all
    @user = User.create!(nickname: "testuser_#{SecureRandom.hex(4)}", password: "password", password_confirmation: "password")
    post "/login", nickname: @user.nickname, password: "password"
    follow_redirect!
  end

  describe "GET /esteem" do
    it "shows empty esteem calendar" do
      get "/esteem"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Self-Esteem Exercise Calendar"
    end
  end

  describe "GET /esteem/new" do
    it "renders the new esteem form" do
      get "/esteem/new"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Self-esteem exercise"
    end
  end

  describe "POST /esteem" do
    it "creates a new esteem with valid parameters" do
      expect {
        post "/esteem", esteem: true
      }.to change(Esteem, :count).by(1)
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include ".completed"
    end
  end
end
