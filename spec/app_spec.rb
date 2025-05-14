require "spec_helper"

RSpec.describe "User Authentication" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    Need.delete_all
    User.delete_all
  end

  it "signs up a new user" do
    post "/signup", nickname: "foobar", password: "password", password_confirmation: "password"
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_response.body).to include "Welcome"
  end

  it "fails on invalid signup" do
    post "/signup", nickname: "foo", password: "pass", password_confirmation: "wrong"
    expect(last_response.body).to include "error"
  end

  it "logs in existing user" do
    User.create(nickname: "foobar", password: "password", password_confirmation: "password")
    post "/login", nickname: "foobar", password: "password"
    expect(last_response).to be_redirect
  end

  it "fails login with wrong credentials" do
    post "/login", nickname: "foo", password: "wrong"
    expect(last_response.body).to include "Invalid nickname or password"
  end
end
