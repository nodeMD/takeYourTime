require_relative "../app"

class ChecklistController < Sinatra::Base
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
    @page = params[:page].to_i || 1
    @checklists = current_user.checklists.order(created_at: :desc).paginate(page: @page, per_page: 30)
    erb :'checklist/index'
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
