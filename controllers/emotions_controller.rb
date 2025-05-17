require_relative '../models/emotion'

class EmotionsController < Sinatra::Base
  # Explicitly set views and layout
  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)
  set :layout, File.expand_path("../../views/layout.erb", __FILE__)
  register Sinatra::ActiveRecordExtension
  enable :sessions

  helpers do
    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
  end

  # Step 1: Main emotion selection
  get '/emotion/new' do
    erb :"emotions/emotions_new", layout: :layout
  end

  # Step 2: Strength and sub-emotion selection + confirmation
  post '/emotion/confirm' do
    @main_emotion = params[:main_emotion]
    @strength = params[:strength]
    @emotion = params[:emotion]
    erb :"emotions/emotions_confirm", layout: :layout
  end

  # Step 3: Save to DB and redirect to index
  post '/emotion' do
    unless current_user
      redirect '/login'
    end
    Emotion.create!(user_id: current_user.id, main_emotion: params[:main_emotion], strength: params[:strength], emotion: params[:emotion])
    redirect '/emotion'
  end

  # List all user's emotions with pagination
  get '/emotion' do
    unless current_user
      redirect '/login'
    end
    per_page = 30
    @page = (params[:page] || 1).to_i
    total_emotions = Emotion.where(user_id: current_user.id).count
    @total_pages = (total_emotions / per_page.to_f).ceil
    offset = (@page - 1) * per_page
    @emotions = Emotion.where(user_id: current_user.id)
                      .order(created_at: :desc)
                      .limit(per_page)
                      .offset(offset)
    erb :"emotions/emotions_index", layout: :layout
  end
end
