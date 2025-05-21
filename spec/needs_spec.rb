require "spec_helper"

RSpec.describe "Needs Management", type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    @user = User.create!(nickname: "testuser_#{SecureRandom.hex(4)}", password: "password", password_confirmation: "password")
    post "/login", nickname: @user.nickname, password: "password"
    follow_redirect!
  end

  describe "GET /need" do
    it "shows empty needs list" do
      get "/need"
      expect(last_response).to be_ok
      expect(last_response.body).to include "No needs yet"
    end

    it "lists all needs for the current user" do
      @user.needs.create!(what: "Need 1", benefits: "B1", cons: "C1")
      @user.needs.create!(what: "Need 2", benefits: "B2", cons: "C2")
      get "/need"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Need 1"
      expect(last_response.body).to include "Need 2"
    end
  end

  describe "GET /need/new" do
    it "renders the new need form" do
      get "/need/new"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Create New Need"
    end
  end

  describe "POST /need" do
    it "creates a new need with valid parameters" do
      expect {
        post "/need", what: "Test Need", benefits: "Benefit1", cons: "Con1"
      }.to change(Need, :count).by(1)
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include "Test Need"
    end

    it "does not create a need with invalid parameters" do
      expect {
        post "/need", what: "", benefits: "Benefit1", cons: "Con1"
      }.not_to change(Need, :count)
      expect(last_response).to be_ok
      expect(last_response.body).to include "can't be blank"
    end
  end

  describe "GET /need/:id" do
    it "shows a single need" do
      need = @user.needs.create!(what: "MyNeed", benefits: "B", cons: "C")
      get "/need/#{need.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to include "MyNeed"
      expect(last_response.body).to include "B"
      expect(last_response.body).to include "C"
    end

    it "handles non-existent need gracefully" do
      get "/need/99999"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Need not found"
    end
  end

  describe "GET /need/:id/edit" do
    it "renders the edit form" do
      need = @user.needs.create!(what: "OldNeed", benefits: "B", cons: "C")
      get "/need/#{need.id}/edit"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Edit Need"
    end
  end

  describe "POST /need/:id" do
    it "updates an existing need" do
      need = @user.needs.create!(what: "OldNeed", benefits: "B", cons: "C")
      post "/need/#{need.id}", what: "UpdatedNeed", benefits: "B2", cons: "C2"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include "UpdatedNeed"
    end

    it "does not update with invalid parameters" do
      need = @user.needs.create!(what: "OldNeed", benefits: "B", cons: "C")
      post "/need/#{need.id}", what: "", benefits: "B2", cons: "C2"
      expect(last_response).to be_ok
      expect(last_response.body).to include "can't be blank"
    end
  end

  describe "POST /need/:id/delete" do
    it "deletes a need" do
      need = @user.needs.create!(what: "ToDelete", benefits: "B", cons: "C")
      post "/need/#{need.id}/delete"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).not_to include "ToDelete"
      expect(Need.find_by(id: need.id)).to be_nil
    end

    it "handles non-existent need deletion gracefully" do
      post "/need/99999/delete"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include "No needs yet"
    end
  end
end
