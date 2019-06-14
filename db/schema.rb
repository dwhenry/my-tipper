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

ActiveRecord::Schema.define(version: 20190614202733) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "fixtures", force: :cascade do |t|
    t.string   "round"
    t.integer  "home_id"
    t.integer  "away_id"
    t.string   "venue"
    t.datetime "at"
    t.integer  "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "event"
  end

  add_index "fixtures", ["away_id"], name: "index_fixtures_on_away_id", using: :btree
  add_index "fixtures", ["event"], name: "index_fixtures_on_event", using: :btree
  add_index "fixtures", ["home_id"], name: "index_fixtures_on_home_id", using: :btree

  create_table "leagues", force: :cascade do |t|
    t.string   "name"
    t.string   "password"
    t.string   "code"
    t.boolean  "public"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "event",      default: false
  end

  create_table "picks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "fixture_id"
    t.integer  "pick"
    t.integer  "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "picks", ["fixture_id"], name: "index_picks_on_fixture_id", using: :btree
  add_index "picks", ["user_id"], name: "index_picks_on_user_id", using: :btree

  create_table "players", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "players", ["league_id"], name: "index_players_on_league_id", using: :btree
  add_index "players", ["user_id"], name: "index_players_on_user_id", using: :btree

  create_table "sents", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "fixture_id"
    t.string   "email_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sents", ["fixture_id"], name: "index_sents_on_fixture_id", using: :btree
  add_index "sents", ["user_id"], name: "index_sents_on_user_id", using: :btree

  create_table "team_wrappers", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "team_wrappers", ["team_id"], name: "index_team_wrappers_on_team_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "short_name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.integer  "team_id"
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "email_notification",     default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "picks", "fixtures"
  add_foreign_key "picks", "users"
  add_foreign_key "players", "leagues"
  add_foreign_key "players", "users"
  add_foreign_key "sents", "fixtures"
  add_foreign_key "sents", "users"
  add_foreign_key "team_wrappers", "teams"
end
