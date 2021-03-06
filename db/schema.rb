# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160520043806) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bgg_item_data", force: :cascade do |t|
    t.string   "item_type"
    t.string   "image"
    t.string   "thumbnail"
    t.string   "name"
    t.text     "description"
    t.integer  "year_published"
    t.integer  "min_players"
    t.integer  "max_players"
    t.integer  "playing_time"
    t.integer  "min_playing_time"
    t.integer  "max_playing_time"
    t.integer  "user_ratings"
    t.float    "average"
    t.float    "bayes"
    t.float    "stddev"
    t.float    "median"
    t.integer  "owned"
    t.integer  "trading"
    t.integer  "wanting"
    t.integer  "wishing"
    t.integer  "num_comments"
    t.integer  "num_weights"
    t.integer  "average_weight"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "bgg_item_data_ranks", force: :cascade do |t|
    t.integer  "bgg_item_data_id", null: false
    t.string   "rank_type"
    t.string   "name"
    t.string   "friendly_name"
    t.integer  "value"
    t.float    "bayes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "bgg_item_data_ranks", ["bgg_item_data_id"], name: "index_bgg_item_data_ranks_on_bgg_item_data_id", using: :btree

  create_table "bgg_user_data", force: :cascade do |t|
    t.string   "name"
    t.string   "avatar"
    t.integer  "year_registered"
    t.string   "state"
    t.integer  "trade_rating"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "math_trade_items", force: :cascade do |t|
    t.integer  "bgg_item_id",   default: -1,    null: false
    t.integer  "user_id",                       null: false
    t.integer  "math_trade_id",                 null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "alt_name"
    t.boolean  "did_trade",     default: false
    t.datetime "deleted_at"
  end

  add_index "math_trade_items", ["deleted_at"], name: "index_math_trade_items_on_deleted_at", using: :btree
  add_index "math_trade_items", ["math_trade_id"], name: "index_math_trade_items_on_math_trade_id", using: :btree
  add_index "math_trade_items", ["user_id"], name: "index_math_trade_items_on_user_id", using: :btree

  create_table "math_trade_read_receipts", force: :cascade do |t|
    t.integer  "math_trade_item_id", null: false
    t.integer  "user_id",            null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "math_trade_read_receipts", ["math_trade_item_id"], name: "index_math_trade_read_receipts_on_math_trade_item_id", using: :btree
  add_index "math_trade_read_receipts", ["user_id"], name: "index_math_trade_read_receipts_on_user_id", using: :btree

  create_table "math_trade_want_confirmations", force: :cascade do |t|
    t.integer  "math_trade_id", null: false
    t.integer  "user_id",       null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "math_trade_want_confirmations", ["math_trade_id"], name: "index_math_trade_want_confirmations_on_math_trade_id", using: :btree
  add_index "math_trade_want_confirmations", ["user_id"], name: "index_math_trade_want_confirmations_on_user_id", using: :btree

  create_table "math_trade_want_items", force: :cascade do |t|
    t.integer  "math_trade_want_id", null: false
    t.integer  "math_trade_item_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "math_trade_want_items", ["math_trade_item_id"], name: "index_math_trade_want_items_on_math_trade_item_id", using: :btree
  add_index "math_trade_want_items", ["math_trade_want_id"], name: "index_math_trade_want_items_on_math_trade_want_id", using: :btree

  create_table "math_trade_wants", force: :cascade do |t|
    t.integer  "user_id",            null: false
    t.integer  "math_trade_id",      null: false
    t.integer  "math_trade_item_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "math_trade_wants", ["math_trade_id"], name: "index_math_trade_wants_on_math_trade_id", using: :btree
  add_index "math_trade_wants", ["math_trade_item_id"], name: "index_math_trade_wants_on_math_trade_item_id", using: :btree
  add_index "math_trade_wants", ["user_id"], name: "index_math_trade_wants_on_user_id", using: :btree

  create_table "math_trades", force: :cascade do |t|
    t.string   "name",                              null: false
    t.integer  "moderator_id",                      null: false
    t.text     "description"
    t.integer  "status",            default: 0,     null: false
    t.datetime "offer_deadline",                    null: false
    t.datetime "wants_deadline",                    null: false
    t.boolean  "shipping",          default: false, null: false
    t.integer  "discussion_thread"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "deleted_at"
    t.binary   "results_list"
    t.datetime "finalized_at"
  end

  add_index "math_trades", ["deleted_at"], name: "index_math_trades_on_deleted_at", using: :btree
  add_index "math_trades", ["moderator_id"], name: "index_math_trades_on_moderator_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                         default: "",    null: false
    t.string   "encrypted_password",            default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "bgg_account"
    t.string   "bgg_account_verification_code"
    t.boolean  "bgg_account_verified",          default: false, null: false
    t.integer  "bgg_user_data_id"
  end

  add_index "users", ["bgg_user_data_id"], name: "index_users_on_bgg_user_data_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "want_group_items", force: :cascade do |t|
    t.integer  "want_group_id",      null: false
    t.integer  "math_trade_item_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "want_group_items", ["math_trade_item_id"], name: "index_want_group_items_on_math_trade_item_id", using: :btree
  add_index "want_group_items", ["want_group_id"], name: "index_want_group_items_on_want_group_id", using: :btree

  create_table "want_group_links", force: :cascade do |t|
    t.integer  "want_group_id",      null: false
    t.integer  "math_trade_want_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "want_group_links", ["math_trade_want_id"], name: "index_want_group_links_on_math_trade_want_id", using: :btree
  add_index "want_group_links", ["want_group_id"], name: "index_want_group_links_on_want_group_id", using: :btree

  create_table "want_groups", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.integer  "math_trade_id", null: false
    t.string   "name",          null: false
    t.string   "short_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "want_groups", ["math_trade_id"], name: "index_want_groups_on_math_trade_id", using: :btree
  add_index "want_groups", ["user_id"], name: "index_want_groups_on_user_id", using: :btree

  add_foreign_key "bgg_item_data_ranks", "bgg_item_data"
  add_foreign_key "math_trade_items", "math_trades"
  add_foreign_key "math_trade_items", "users"
  add_foreign_key "math_trade_read_receipts", "math_trade_items"
  add_foreign_key "math_trade_read_receipts", "users"
  add_foreign_key "math_trade_want_confirmations", "math_trades"
  add_foreign_key "math_trade_want_confirmations", "users"
  add_foreign_key "math_trade_want_items", "math_trade_items"
  add_foreign_key "math_trade_want_items", "math_trade_wants"
  add_foreign_key "math_trade_wants", "math_trade_items"
  add_foreign_key "math_trade_wants", "math_trades"
  add_foreign_key "math_trade_wants", "users"
  add_foreign_key "math_trades", "users", column: "moderator_id"
  add_foreign_key "users", "bgg_user_data"
  add_foreign_key "want_group_items", "math_trade_items"
  add_foreign_key "want_group_items", "want_groups"
  add_foreign_key "want_group_links", "math_trade_wants"
  add_foreign_key "want_group_links", "want_groups"
  add_foreign_key "want_groups", "math_trades"
  add_foreign_key "want_groups", "users"
end
