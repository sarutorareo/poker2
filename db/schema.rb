# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170107100913) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hand_users", force: :cascade do |t|
    t.integer  "hand_id",                      null: false
    t.integer  "user_id",                      null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "tern_order",       default: 0, null: false
    t.integer  "last_action_kbn"
    t.integer  "hand_total_chip",  default: 0, null: false
    t.string   "user_hand_str"
    t.integer  "last_action_chip", default: 0, null: false
    t.integer  "round_total_chip", default: 0, null: false
    t.index ["hand_id"], name: "index_hand_users_on_hand_id", using: :btree
    t.index ["user_id"], name: "index_hand_users_on_user_id", using: :btree
  end

  create_table "hands", force: :cascade do |t|
    t.integer  "room_id",                    null: false
    t.integer  "button_user_id",             null: false
    t.integer  "tern_user_id",               null: false
    t.integer  "bb"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "deck_str"
    t.string   "board_str"
    t.string   "burned_str"
    t.integer  "betting_round",  default: 0, null: false
    t.integer  "call_chip",      default: 0, null: false
    t.integer  "min_raise_chip", default: 0, null: false
    t.index ["room_id"], name: "index_hands_on_room_id", using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "room_id",    default: 1
    t.string   "user_name"
    t.index ["room_id"], name: "index_messages_on_room_id", using: :btree
  end

  create_table "room_users", force: :cascade do |t|
    t.integer  "room_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id", "user_id"], name: "index_room_users_on_room_id_and_user_id", unique: true, using: :btree
    t.index ["room_id"], name: "index_room_users_on_room_id", using: :btree
    t.index ["user_id"], name: "index_room_users_on_user_id", using: :btree
  end

  create_table "rooms", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   null: false
    t.integer  "chip",       default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_type",  default: 0, null: false
  end

  add_foreign_key "hand_users", "hands"
  add_foreign_key "hand_users", "users"
  add_foreign_key "hands", "rooms"
  add_foreign_key "hands", "users", column: "button_user_id"
  add_foreign_key "hands", "users", column: "tern_user_id"
  add_foreign_key "messages", "rooms"
  add_foreign_key "room_users", "rooms"
  add_foreign_key "room_users", "users"
end
