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

ActiveRecord::Schema[8.0].define(version: 2025_02_10_210859) do
  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.string "genre"
    t.integer "duration"
    t.string "language"
    t.string "rating"
    t.date "release_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "screens", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shows", force: :cascade do |t|
    t.integer "movie_id", null: false
    t.integer "screen_id", null: false
    t.date "date"
    t.time "time"
    t.integer "available_seats"
    t.decimal "ticket_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_shows_on_movie_id"
    t.index ["screen_id"], name: "index_shows_on_screen_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "show_id", null: false
    t.string "confirmation_number"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["show_id"], name: "index_tickets_on_show_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "email"
    t.string "password"
    t.string "phone"
    t.text "address"
    t.string "credit_card_info"
    t.boolean "is_admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "shows", "movies"
  add_foreign_key "shows", "screens"
  add_foreign_key "tickets", "shows"
  add_foreign_key "tickets", "users"
end
