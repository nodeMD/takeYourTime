class NeedsController < Sinatra::Base
  # Explicitly set views and layout
  set :views, File.expand_path("../../views", __FILE__)
  set :public_folder, File.expand_path("../../public", __FILE__)
  set :layout, File.expand_path("../../views/layout.erb", __FILE__)
  register Sinatra::ActiveRecordExtension
  enable :sessions

  # Make current_user available in modular controller
  helpers do
    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
  end

  # Needs listing with pagination
  get "/need" do
    redirect "/login" unless current_user
    per_page = 20
    @page = (params[:page] || 1).to_i
    total = current_user.needs.count
    @total_pages = (total / per_page.to_f).ceil
    if @page < 1 || (@total_pages > 0 && @page > @total_pages)
      redirect '/need?page=1'
    end
    @needs = current_user.needs.order(:id).limit(per_page).offset((@page - 1) * per_page)
    @title = "Your Needs"
    erb :"needs/needs_index", layout: :layout
  end

  get "/need/new" do
    redirect "/login" unless current_user
    @title = "New Need"
    erb :"needs/needs_new", layout: :layout
  end

  # Edit need form
  get "/need/:id/edit" do
    redirect "/login" unless current_user
    @need = current_user.needs.find(params[:id])
    @title = "Edit Need ##{@need.id}"
    erb :"needs/needs_edit", layout: :layout
  end

  get "/need/:id" do
    redirect "/login" unless current_user
    @need = current_user.needs.find(params[:id])
    @title = "Need ##{@need.id}"
    erb :"needs/needs_show", layout: :layout
  end

  post "/need" do
    redirect "/login" unless current_user
    need = current_user.needs.new(what: params[:what], benefits: params[:benefits], cons: params[:cons])
    if need.save
      redirect "/need"
    else
      @errors = need.errors.full_messages
      @title = "New Need"
      erb :"needs/needs_new", layout: :layout
    end
  end

  # Update need
  post "/need/:id" do
    redirect "/login" unless current_user
    @need = current_user.needs.find(params[:id])
    if @need.update(what: params[:what], benefits: params[:benefits], cons: params[:cons])
      redirect "/need/#{@need.id}"
    else
      @errors = @need.errors.full_messages
      @title = "Edit Need ##{@need.id}"
      erb :"needs/needs_edit", layout: :layout
    end
  end

  # Delete a need
  post "/need/:id/delete" do
    redirect "/login" unless current_user
    need = current_user.needs.find(params[:id])
    need.destroy
    redirect "/need"
  end
end
