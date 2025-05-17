require "sinatra"
require "sinatra/activerecord"
require "dotenv/load"
require "rack/session/cookie"
require "./models/user"
require "./models/need"
require "./models/want"
require_relative "controllers/needs_controller"
require_relative "controllers/wants_controller"
require_relative "controllers/emotions_controller"
use NeedsController
use WantsController
use EmotionsController

# Configure session settings
set :sessions, {
  key: 'takeyourtime_session',
  secret: ENV['SESSION_SECRET'] || SecureRandom.hex(64),
  expire_after: 20 * 60, # 20 minutes
  secure: ENV['RACK_ENV'] == 'production',
  httponly: true,
  path: '/',
  same_site: :strict
}

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
  if session[:user_id]
    redirect "/app"
  end
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
  if session[:user_id]
    redirect "/app"
  end
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
  redirect "/login"
end

# Add before filter for all routes
before do
  headers "Cache-Control" => "no-store, no-cache, must-revalidate",
          "Pragma" => "no-cache",
          "Expires" => "0",
          "X-Frame-Options" => "DENY",
          "X-Content-Type-Options" => "nosniff"
end

# Add before filter for protected routes
before %r{/app|need|want|emotion|podcast} do
  if !current_user
    redirect "/login"
  end
end

get "/app" do
  @title = "Welcome #{current_user.nickname}"
  erb :app
end

# --- Podcast routes ---
require "pathname"
require "kramdown"

get "/podcast" do
  # Gather all episodes
  podcast_dir = File.join(settings.public_folder, "podcasts")
  episodes = Dir.entries(podcast_dir).select { |entry| entry =~ /^episode\d+$/ }
  episodes = episodes.map do |ep_dir|
    ep_path = File.join(podcast_dir, ep_dir)
    mp3 = Dir.entries(ep_path).find { |f| f.end_with?(".mp3") }
    next unless mp3
    {
      number: ep_dir.gsub("episode", "").to_i,
      title: mp3,
      dir: ep_dir,
      mp3: mp3,
      text_path: File.join(ep_path, "text.md")
    }
  end.compact
  # Sort from newest to oldest
  episodes = episodes.sort_by { |ep| -ep[:number] }

  # Search
  query = params[:q]&.strip
  if query && !query.empty?
    episodes = episodes.select do |ep|
      mp3_match = ep[:title].downcase.include?(query.downcase)
      text_match = File.exist?(ep[:text_path]) && File.read(ep[:text_path]).downcase.include?(query.downcase)
      mp3_match || text_match
    end
  end

  # Pagination
  per_page = 20
  page = (params[:page] || 1).to_i
  total_pages = (episodes.size / per_page.to_f).ceil
  page = 1 if page < 1 || (total_pages > 0 && page > total_pages)
  episodes_paginated = episodes.slice((page - 1) * per_page, per_page) || []

  erb :"podcast/podcast_index", locals: {
    episodes: episodes_paginated,
    page: page,
    total_pages: total_pages,
    query: query
  }, layout: :layout
end

get "/podcast/:episode_title" do
  podcast_dir = File.join(settings.public_folder, "podcasts")
  # Find episode by mp3 file name
  episode = nil
  Dir.entries(podcast_dir).select { |entry| entry =~ /^episode\d+$/ }.each do |ep_dir|
    ep_path = File.join(podcast_dir, ep_dir)
    mp3 = Dir.entries(ep_path).find { |f| f == params[:episode_title] }
    if mp3
      episode = {
        dir: ep_dir,
        mp3: mp3,
        mp3_path: "/podcasts/#{ep_dir}/#{mp3}",
        text_path: File.join(ep_path, "text.md")
      }
      break
    end
  end
  halt 404, "Episode not found" unless episode
  text_html = File.exist?(episode[:text_path]) ? Kramdown::Document.new(File.read(episode[:text_path])).to_html : "<em>No description available.</em>"
  erb :"podcast/podcast_show", locals: {episode: episode, text_html: text_html}, layout: :layout
end
