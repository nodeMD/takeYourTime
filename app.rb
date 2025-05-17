require "sinatra"
require "sinatra/activerecord"
require "./models/user"
require "./models/need"
require "./models/want"
require_relative "controllers/needs_controller"
require_relative "controllers/wants_controller"
require_relative "controllers/emotions_controller"
use NeedsController
use WantsController
use EmotionsController

set :database_file, "config/database.yml"
enable :sessions

helpers do
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
end

get "/" do
  erb :index
end

get "/signup" do
  @user = User.new
  erb :signup
end

post "/signup" do
  @user = User.new(nickname: params[:nickname], password: params[:password], password_confirmation: params[:password_confirmation])
  if @user.save
    session[:user_id] = @user.id
    redirect "/app"
  else
    erb :signup
  end
end

get "/login" do
  @error = nil
  erb :login
end

post "/login" do
  user = User.find_by(nickname: params[:nickname])
  if user&.authenticate(params[:password])
    session[:user_id] = user.id
    redirect "/app"
  else
    @error = "Invalid nickname or password"
    erb :login
  end
end

get "/logout" do
  session.clear
  redirect "/"
end

get "/app" do
  redirect "/" unless current_user
  @title = "Welcome #{current_user.nickname}"
  erb :app
end
