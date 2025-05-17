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
    redirect "/login" unless current_user
    per_page = 20
    @page = (params[:page] || 1).to_i
    total = current_user.wants.count
    @total_pages = (total / per_page.to_f).ceil
    if @page < 1 || (@total_pages > 0 && @page > @total_pages)
      redirect '/want?page=1'
    end
    @wants = current_user.wants.order(:id).limit(per_page).offset((@page - 1) * per_page)
    @title = "Your Wants"
    erb :"wants/wants_index", layout: :layout
  end

  get "/want/new" do
    redirect "/login" unless current_user
    @title = "New Want"
    erb :"wants/wants_new", layout: :layout
  end

  # Edit want form
  get "/want/:id/edit" do
    redirect "/login" unless current_user
    @want = current_user.wants.find(params[:id])
    @title = "Edit Want ##{@want.id}"
    erb :"wants/wants_edit", layout: :layout
  end

  get "/want/:id" do
    redirect "/login" unless current_user
    @want = current_user.wants.find(params[:id])
    @title = "Want ##{@want.id}"
    erb :"wants/wants_show", layout: :layout
  end

  post "/want" do
    redirect "/login" unless current_user
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
    redirect "/login" unless current_user
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
    redirect "/login" unless current_user
    want = current_user.wants.find(params[:id])
    want.destroy
    redirect "/want"
  end
end
