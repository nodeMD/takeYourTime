require_relative "../app"

class ChecklistController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)
  set :layout, File.expand_path("../../views/layout.erb", __FILE__)
  include Rack::Utils

  helpers do
    def current_user
      User.find(session[:user_id]) if session[:user_id]
    end
  end

  get '/checklist' do
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

  get '/checklist/new' do
    unless current_user
      redirect "/login"
    end
    @checklist = Checklist.new
    erb :'checklist/new'
  end

  post '/checklist' do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.build(params[:checklist])
    if @checklist.save
      redirect '/checklist'
    else
      erb :'checklist/new'
    end
  end

  get '/checklist/:id' do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.find(params[:id])
    erb :'checklist/show'
  end

  get '/checklist/:checklist_id/items/new' do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.find(params[:checklist_id])
    @item = ChecklistItem.new
    erb :'checklist/items/new'
  end

  post '/checklist/:checklist_id/items' do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.find(params[:checklist_id])
    @item = @checklist.checklist_items.build(params[:checklist_item])
    if @item.save
      redirect "/checklist/#{@checklist.id}"
    else
      erb :'checklist/items/new'
    end
  end

  post '/checklist/:checklist_id/items/:id/toggle' do
    unless current_user
      redirect "/login"
    end
    @checklist = current_user.checklists.find(params[:checklist_id])
    @item = @checklist.checklist_items.find(params[:id])
    @item.update(completed: !@item.completed)
    redirect "/checklist/#{@checklist.id}"
  end
end
