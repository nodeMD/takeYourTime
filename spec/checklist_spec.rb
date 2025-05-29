require "spec_helper"

RSpec.describe "Checklist Management", type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def session
    last_request.env["rack.session"]
  end

  def login_user(user)
    post "/login", {nickname: user.nickname, password: "password"}
    follow_redirect!
    expect(last_response.redirect?).to be_falsey
  end

  before(:all) do
    # Create test users once
    @user = User.create!(nickname: "testuser_#{SecureRandom.hex(4)}",
      password: "password",
      password_confirmation: "password")
    @other_user = User.create!(nickname: "otheruser_#{SecureRandom.hex(4)}",
      password: "password",
      password_confirmation: "password")
  end

  before(:each) do
    # Clear data before each test
    ChecklistItem.destroy_all
    Checklist.destroy_all
    User.where("id NOT IN (?)", [@user.id, @other_user.id]).destroy_all

    # Create test data for each test
    @checklist = @user.checklists.create!(name: "Test Checklist")
    @checklist_item = @checklist.checklist_items.create!(name: "Test Item")

    # Login before each test
    post "/login", {nickname: @user.nickname, password: "password"}
    follow_redirect!
  end

  let(:user) { @user }
  let(:other_user) { @other_user }
  let(:checklist) { @checklist }
  let(:checklist_item) { @checklist_item }

  describe "GET /checklist" do
    it "requires authentication" do
      get "/logout"
      get "/checklist"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq("/login")
    end

    it "shows empty state when no checklists exist" do
      Checklist.destroy_all
      get "/checklist"
      expect(last_response).to be_ok
      expect(last_response.body).to include("You don't have any checklists yet")
    end

    it "lists all checklists for the current user" do
      # Create a second checklist for the user
      user.checklists.create!(name: "Another Test Checklist")

      get "/checklist"
      expect(last_response).to be_ok
      expect(last_response.body).to include("Test Checklist")
      expect(last_response.body).to include("Another Test Checklist")
    end
  end

  describe "GET /checklist/new" do
    it "shows the new checklist form" do
      get "/checklist/new"
      expect(last_response).to be_ok
      expect(last_response.body).to include("New Checklist")
    end
  end

  describe "POST /checklist" do
    it "creates a new checklist with valid parameters" do
      expect {
        post "/checklist", {checklist: {name: "New Test Checklist"}}
      }.to change(Checklist, :count).by(1)
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include("New Test Checklist")
    end

    it "shows errors with invalid parameters" do
      post "/checklist", {checklist: {name: ""}}
      expect(last_response).to be_ok
      # The error might be shown in a flash message or in the form
      expect(last_response.body).to include("New Checklist") # Still on the new form
    end
  end

  describe "GET /checklist/:id" do
    it "shows the requested checklist" do
      get "/checklist/#{checklist.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to include("Test Checklist")
    end

    it "prevents accessing other users' checklists" do
      other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
      expect {
        get "/checklist/#{other_checklist.id}"
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET /checklist/:id/edit" do
    it "shows the edit form" do
      get "/checklist/#{checklist.id}/edit"
      expect(last_response).to be_ok
      expect(last_response.body).to include("Edit Checklist")
      expect(last_response.body).to include(checklist.name)
    end

    it "prevents editing other users' checklists" do
      other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
      expect {
        get "/checklist/#{other_checklist.id}/edit"
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "PUT /checklist/:id" do
    it "updates the checklist" do
      put "/checklist/#{checklist.id}", {checklist: {name: "Updated Checklist Name"}}
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include("Updated Checklist Name")
    end

    it "shows errors with invalid parameters" do
      put "/checklist/#{checklist.id}", {checklist: {name: ""}}
      expect(last_response).to be_ok
      # The error might be shown in the form
      expect(last_response.body).to include("Edit Checklist")
    end

    it "prevents updating other users' checklists" do
      other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
      original_name = other_checklist.name
      expect {
        put "/checklist/#{other_checklist.id}", {checklist: {name: "Hacked Checklist"}}
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(other_checklist.reload.name).to eq(original_name)
    end
  end

  describe "DELETE /checklist/:id" do
    it "deletes the checklist" do
      checklist_to_delete = user.checklists.create!(name: "To Delete")
      expect {
        delete "/checklist/#{checklist_to_delete.id}"
      }.to change(Checklist, :count).by(-1)
      expect(last_response).to be_redirect
      follow_redirect!
      # Check for any success message or redirection to index
      expect(["/checklist", "/"].include?(last_request.path)).to be true
    end

    it "prevents deleting other users' checklists" do
      other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
      expect {
        delete "/checklist/#{other_checklist.id}"
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Checklist.exists?(other_checklist.id)).to be true
    end
  end

  describe "Checklist Items" do
    describe "POST /checklist/:checklist_id/items" do
      it "creates a new checklist item" do
        expect {
          post "/checklist/#{checklist.id}/items", {checklist_item: {name: "New Test Item"}}
        }.to change(ChecklistItem, :count).by(1)
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include("New Test Item")
      end

      it "shows errors with invalid parameters" do
        expect {
          post "/checklist/#{checklist.id}/items", {checklist_item: {name: ""}}
        }.not_to change(ChecklistItem, :count)
        expect(last_response).to be_ok
        # Check that we're still on the new item form
        expect(last_response.body).to include("Add New Item to")
      end

      it "prevents adding items to other users' checklists" do
        other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
        expect {
          post "/checklist/#{other_checklist.id}/items", {checklist_item: {name: "Hacked Item"}}
        }.to raise_error(ActiveRecord::RecordNotFound)
        expect(ChecklistItem.where(checklist_id: other_checklist.id).count).to eq(0)
      end
    end

    describe "GET /checklist/:checklist_id/items/:id/edit" do
      it "shows the edit form for an item" do
        get "/checklist/#{checklist.id}/items/#{checklist_item.id}/edit"
        expect(last_response).to be_ok
        expect(last_response.body).to include("Edit Item")
        expect(last_response.body).to include(checklist_item.name)
      end

      it "prevents editing items from other users' checklists" do
        other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
        other_item = other_checklist.checklist_items.create!(name: "Other Item")

        expect {
          get "/checklist/#{other_checklist.id}/items/#{other_item.id}/edit"
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "PUT /checklist/:checklist_id/items/:id" do
      it "updates the checklist item" do
        put "/checklist/#{checklist.id}/items/#{checklist_item.id}", {checklist_item: {name: "Updated Test Item"}}
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include("Updated Test Item")
      end

      it "shows errors with invalid parameters" do
        put "/checklist/#{checklist.id}/items/#{checklist_item.id}", {checklist_item: {name: ""}}
        expect(last_response).to be_ok
        # Check that we're still on the edit form
        expect(last_response.body).to include("Edit Item")
      end

      it "prevents updating items from other users' checklists" do
        other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
        other_item = other_checklist.checklist_items.create!(name: "Other Item")
        original_name = other_item.name

        expect {
          put "/checklist/#{other_checklist.id}/items/#{other_item.id}", {checklist_item: {name: "Hacked Item"}}
        }.to raise_error(ActiveRecord::RecordNotFound)
        expect(other_item.reload.name).to eq(original_name)
      end
    end

    describe "POST /checklist/:checklist_id/items/:id/toggle" do
      it "toggles the completed status" do
        expect {
          post "/checklist/#{checklist.id}/items/#{checklist_item.id}/toggle"
        }.to change { checklist_item.reload.completed }.from(false).to(true)

        expect {
          post "/checklist/#{checklist.id}/items/#{checklist_item.id}/toggle"
        }.to change { checklist_item.reload.completed }.from(true).to(false)
      end

      it "prevents toggling items from other users' checklists" do
        other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
        other_item = other_checklist.checklist_items.create!(name: "Other Item")
        original_status = other_item.completed

        expect {
          post "/checklist/#{other_checklist.id}/items/#{other_item.id}/toggle"
        }.to raise_error(ActiveRecord::RecordNotFound)

        expect(other_item.reload.completed).to eq(original_status)
      end
    end

    describe "DELETE /checklist/:checklist_id/items/:id" do
      it "deletes the checklist item" do
        item = checklist.checklist_items.create!(name: "Item to delete")
        expect {
          delete "/checklist/#{checklist.id}/items/#{item.id}"
        }.to change(ChecklistItem, :count).by(-1)
        expect(last_response).to be_redirect
      end

      it "prevents deleting items from other users' checklists" do
        other_checklist = other_user.checklists.create!(name: "Other User's Checklist")
        other_item = other_checklist.checklist_items.create!(name: "Other Item")

        expect {
          delete "/checklist/#{other_checklist.id}/items/#{other_item.id}"
        }.to raise_error(ActiveRecord::RecordNotFound)

        expect(ChecklistItem.find_by(id: other_item.id)).to be_present
      end
    end
  end

  describe "Checklist model" do
    it "calculates completion percentage correctly" do
      checklist = user.checklists.create!(name: "Test Completion")
      checklist.checklist_items.create!(name: "Item 1", completed: true)
      checklist.checklist_items.create!(name: "Item 2", completed: false)

      expect(checklist.completed_items_count).to eq(1)
      expect(checklist.total_items_count).to eq(2)
      expect(checklist.completion_percentage).to eq(50.0)
    end
  end
end
