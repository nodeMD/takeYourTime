class WantsController < Sinatra::Base
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

  # Wants listing with pagination
  get "/want" do
    redirect "/" unless current_user
    page = (params[:page] || 1).to_i
    total = current_user.wants.count
    @total_pages = (total / 20.0).ceil
    @page = page
    @wants = current_user.wants.order(:id).limit(20).offset((page - 1) * 20)
    @title = "Your Wants"
    erb :"wants/wants_index", layout: :layout
  end

  get "/want/new" do
    redirect "/" unless current_user
    @title = "New Want"
    erb :"wants/wants_new", layout: :layout
  end

  # Edit want form
  get "/want/:id/edit" do
    redirect "/" unless current_user
    @want = current_user.wants.find(params[:id])
    @title = "Edit Want ##{@want.id}"
    erb :"wants/wants_edit", layout: :layout
  end

  get "/want/:id" do
    redirect "/" unless current_user
    @want = current_user.wants.find(params[:id])
    @title = "Want ##{@want.id}"
    erb :"wants/wants_show", layout: :layout
  end

  post "/want" do
    redirect "/" unless current_user
    want = current_user.wants.new(what: params[:what], how: params[:how])
    if want.save
      redirect "/want"
    else
      @errors = want.errors.full_messages
      @title = "New Want"
      erb :"wants/wants_new", layout: :layout
    end
  end

  # Update want
  post "/want/:id" do
    redirect "/" unless current_user
    @want = current_user.wants.find(params[:id])
    if @want.update(what: params[:what], how: params[:how])
      redirect "/want/#{@want.id}"
    else
      @errors = @want.errors.full_messages
      @title = "Edit Want ##{@want.id}"
      erb :"wants/wants_edit", layout: :layout
    end
  end

  # Delete a want
  post "/want/:id/delete" do
    redirect "/" unless current_user
    want = current_user.wants.find(params[:id])
    want.destroy
    redirect "/want"
  end
end
