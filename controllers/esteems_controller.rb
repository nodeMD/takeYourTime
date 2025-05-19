require_relative "../models/esteem"

class EsteemsController < Sinatra::Base
  # Explicitly set views and layout
  set :views, File.expand_path("../../views", __FILE__)
  set :public_folder, File.expand_path("../../public", __FILE__)
  set :layout, File.expand_path("../../views/layout.erb", __FILE__)
  register Sinatra::ActiveRecordExtension
  enable :sessions

  helpers do
    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
  end

  # Step 1: Main emotion selection
  get "/esteem/new" do
    unless current_user
      redirect "/login"
    end
    erb :"esteems/esteems_new", layout: :layout
  end

  # Step 2: Save to DB and redirect to index
  post "/esteem" do
    unless current_user
      redirect "/login"
    end
    Esteem.create!(user_id: current_user.id, esteem: true)
    redirect "/esteem"
  end

  # List all user's esteems with calendar view
  get "/esteem" do
    unless current_user
      redirect "/login"
    end

    # Get all esteems for the current user
    user_esteems = current_user.esteems

    # Get the current month's first day
    current_month = Date.today.beginning_of_month

    # Create a hash of dates with exercise status
    @calendar_data = {}

    # Add all days of the current month
    (0..31).each do |day|
      date = current_month + day
      if date.month == Date.today.month
        date_key = date.strftime("%Y-%m-%d")
        @calendar_data[date_key] = user_esteems.any? { |e| e.created_at.to_date == date && e.esteem }
      end
    end

    # Add days from the previous month to fill the first week
    first_day_of_month = current_month.beginning_of_month
    days_to_add = first_day_of_month.wday
    (1..days_to_add).each do |day|
      date = first_day_of_month - day
      date_key = date.strftime("%Y-%m-%d")
      @calendar_data[date_key] = user_esteems.any? { |e| e.created_at.to_date == date && e.esteem }
    end

    # Add days from the next month to fill the last week
    last_day_of_month = current_month.end_of_month
    days_to_add = 6 - last_day_of_month.wday
    (1..days_to_add).each do |day|
      date = last_day_of_month + day
      date_key = date.strftime("%Y-%m-%d")
      @calendar_data[date_key] = user_esteems.any? { |e| e.created_at.to_date == date && e.esteem }
    end

    erb :"esteems/esteems_index", layout: :layout
  end
end
