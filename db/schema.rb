# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_07_17_192829) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checklist_items", force: :cascade do |t|
    t.bigint "checklist_id", null: false
    t.string "name", limit: 200, null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position", null: false
    t.index ["checklist_id", "position"], name: "index_checklist_items_on_checklist_id_and_position", unique: true
    t.index ["checklist_id"], name: "index_checklist_items_on_checklist_id"
  end

  create_table "checklists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", limit: 100, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_checklists_on_user_id"
  end

  create_table "emotions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "main_emotion", null: false
    t.string "strength", null: false
    t.string "emotion", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_emotions_on_user_id"
  end

  create_table "esteems", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "esteem", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_esteems_on_user_id"
  end

  create_table "needs", force: :cascade do |t|
    t.string "what", limit: 1000, null: false
    t.text "benefits"
    t.text "cons"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_needs_on_user_id"
  end

  create_table "stoppers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "running", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "time", default: 0, null: false
    t.index ["user_id"], name: "index_stoppers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
  end

  create_table "wants", force: :cascade do |t|
    t.string "what", limit: 1000, null: false
    t.text "how"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_wants_on_user_id"
  end

  add_foreign_key "checklist_items", "checklists"
  add_foreign_key "checklists", "users"
  add_foreign_key "emotions", "users"
  add_foreign_key "esteems", "users", on_delete: :cascade
  add_foreign_key "needs", "users"
  add_foreign_key "stoppers", "users"
  add_foreign_key "wants", "users"
end
