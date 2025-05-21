require "spec_helper"

RSpec.describe "Wants Management", type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    @user = User.create!(nickname: "testuser_#{SecureRandom.hex(4)}", password: "password", password_confirmation: "password")
    post "/login", nickname: @user.nickname, password: "password"
    follow_redirect!
  end

  describe "GET /want" do
    it "shows empty wants list" do
      get "/want"
      expect(last_response).to be_ok
      expect(last_response.body).to include "You do not want anything yet. Create something!"
    end

    it "lists all wants for the current user" do
      @user.wants.create!(what: "Want 1", how: "How 1")
      @user.wants.create!(what: "Want 2", how: "How 2")
      get "/want"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Want 1"
      expect(last_response.body).to include "Want 2"
    end
  end

  describe "GET /want/new" do
    it "renders the new want form" do
      get "/want/new"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Write what you want"
    end
  end

  describe "POST /want" do
    it "creates a new want with valid parameters" do
      expect {
        post "/want", what: "Test Want", how: "Test How"
      }.to change(Want, :count).by(1)
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include "Test Want"
    end

    it "does not create a want with invalid parameters" do
      expect {
        post "/want", what: "", how: "Test How"
      }.not_to change(Want, :count)
      expect(last_response).to be_ok
      expect(last_response.body).to include "can't be blank"
    end
  end

  describe "GET /want/:id" do
    it "shows a single want" do
      want = @user.wants.create!(what: "MyWant", how: "MyHow")
      get "/want/#{want.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to include "MyWant"
      expect(last_response.body).to include "MyHow"
    end

    it "handles non-existent want gracefully" do
      get "/want/99999"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Want not found"
    end
  end

  describe "GET /want/:id/edit" do
    it "renders the edit form" do
      want = @user.wants.create!(what: "OldWant", how: "OldHow")
      get "/want/#{want.id}/edit"
      expect(last_response).to be_ok
      expect(last_response.body).to include "Edit Want ##{want.id}"
    end
  end

  describe "POST /want/:id" do
    it "updates an existing want" do
      want = @user.wants.create!(what: "OldWant", how: "OldHow")
      post "/want/#{want.id}", what: "UpdatedWant", how: "UpdatedHow"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include "UpdatedWant"
    end

    it "does not update with invalid parameters" do
      want = @user.wants.create!(what: "OldWant", how: "OldHow")
      post "/want/#{want.id}", what: "", how: "UpdatedHow"
      expect(last_response).to be_ok
      expect(last_response.body).to include "can't be blank"
    end
  end

  describe "POST /want/:id/delete" do
    it "deletes a want" do
      want = @user.wants.create!(what: "ToDelete", how: "ToDeleteHow")
      post "/want/#{want.id}/delete"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).not_to include "ToDelete"
      expect(Want.find_by(id: want.id)).to be_nil
    end

    it "handles non-existent want deletion gracefully" do
      post "/want/99999/delete"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include "You do not want anything yet. Create something!"
    end
  end
end
