require_relative "../app"

class ChecklistController < Sinatra::Base
  set :views, File.expand_path("../../views", __FILE__)
  set :layout, File.expand_path("../../views/layout.erb", __FILE__)
  include Rack::Utils

  helpers do
    def current_user
      User.find(session[:user_id]) if session[:user_id]
    end

    def not_found
      status 404
      erb :not_found, layout: :layout
    end
  end

  # Handle RecordNotFound errors
  error ActiveRecord::RecordNotFound do
    not_found
  end

  # Handle other 404 errors
  error 404 do
    not_found
  end

  get "/checklist" do
    unless current_user
      redirect "/login"
    end
    per_page = 20
    @page = (params[:page] || 1).to_i
    total = current_user.checklists.count
    @total_pages = (total / per_page.to_f).ceil
    if @page < 1 || (@total_pages > 0 && @page > @total_pages)
      redirect "/checklist?page=1"
    end
    @checklists = current_user.checklists.order(created_at: :desc).limit(per_page).offset((@page - 1) * per_page)
    @title = "Your Checklists"
    erb :"checklist/index", layout: :layout
  end

  get "/checklist/new" do
    unless current_user
      redirect "/login"
    end
    @checklist = Checklist.new
    erb :"checklist/new"
  end

  post "/checklist" do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.build(params[:checklist])
    if @checklist.save
      redirect "/checklist"
    else
      erb :"checklist/new"
    end
  end

  get "/checklist/:id" do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.includes(:checklist_items).find(params[:id])
    @checklist_items = @checklist.checklist_items.order(id: :desc).where("1=1") # Ensures we always return a relation
    erb :"checklist/show"
  end

  get "/checklist/:checklist_id/items/new" do
    unless current_user
      redirect "/login"
    end
    begin
      @checklist = current_user.checklists.find(params[:checklist_id])
      @item = ChecklistItem.new
      erb :"checklist/items/new"
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  post "/checklist/:checklist_id/items" do
    unless current_user
      redirect "/login"
    end
    begin
      @checklist = current_user.checklists.find(params[:checklist_id])
      @item = @checklist.checklist_items.build(params[:checklist_item])
      if @item.save
        redirect "/checklist/#{@checklist.id}"
      else
        erb :"checklist/items/new"
      end
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  get "/checklist/:checklist_id/items/:id/edit" do
    unless current_user
      redirect "/login"
    end
    begin
      @checklist = current_user.checklists.find(params[:checklist_id])
      @item = @checklist.checklist_items.find(params[:id])
      erb :"checklist/items/edit"
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  put "/checklist/:checklist_id/items/:id" do
    unless current_user
      redirect "/login"
    end
    begin
      @checklist = current_user.checklists.find(params[:checklist_id])
      @item = @checklist.checklist_items.find(params[:id])
      if @item.update(params[:checklist_item])
        redirect "/checklist/#{@checklist.id}"
      else
        erb :"checklist/items/edit"
      end
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  delete "/checklist/:checklist_id/items/:id" do
    unless current_user
      redirect "/login"
    end
    begin
      @checklist = current_user.checklists.find(params[:checklist_id])
      @item = @checklist.checklist_items.find(params[:id])
      @item.destroy
      redirect "/checklist/#{@checklist.id}"
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  post "/checklist/:checklist_id/items/:id/toggle" do
    unless current_user
      redirect "/login"
    end
    begin
      @checklist = current_user.checklists.find(params[:checklist_id])
      @item = @checklist.checklist_items.find(params[:id])
      @item.update(completed: !@item.completed)
      redirect "/checklist/#{@checklist.id}"
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  get "/checklist/:id/edit" do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.find(params[:id])
    erb :"checklist/edit"
  end

  put "/checklist/:id" do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.find(params[:id])
    if @checklist.update(params[:checklist])
      redirect "/checklist"
    else
      erb :"checklist/edit"
    end
  end

  delete "/checklist/:id" do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.find(params[:id])
    @checklist.destroy
    redirect "/checklist"
  end
end
