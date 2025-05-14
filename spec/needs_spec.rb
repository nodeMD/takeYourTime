require "spec_helper"

RSpec.describe "Needs Management", type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    Need.delete_all
    User.delete_all
    @user = User.create!(nickname: "foobar", password: "password", password_confirmation: "password")
    post "/login", nickname: "foobar", password: "password"
    follow_redirect!
  end

  it "shows empty needs list" do
    get "/need"
    expect(last_response).to be_ok
    expect(last_response.body).to include "No needs yet"
  end

  it "creates a new need" do
    get "/need/new"
    expect(last_response).to be_ok

    post "/need", what: "Test Need", benefits: "Benefit1", cons: "Con1"
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_response.body).to include "Test Need"
  end

  it "shows a single need" do
    need = @user.needs.create!(what: "MyNeed", benefits: "B", cons: "C")
    get "/need/#{need.id}"
    expect(last_response).to be_ok
    expect(last_response.body).to include "MyNeed"
  end

  it "updates an existing need" do
    need = @user.needs.create!(what: "OldNeed", benefits: "B", cons: "C")
    get "/need/#{need.id}/edit"
    expect(last_response).to be_ok

    post "/need/#{need.id}", what: "UpdatedNeed", benefits: "B2", cons: "C2"
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_response.body).to include "UpdatedNeed"
  end

  it "deletes a need" do
    need = @user.needs.create!(what: "ToDelete", benefits: "B", cons: "C")
    post "/need/#{need.id}/delete"
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_response.body).not_to include "ToDelete"
  end
end
