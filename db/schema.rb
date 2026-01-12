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

ActiveRecord::Schema[8.2].define(version: 2026_01_12_184432) do
  create_table "user_credentials", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "kind"
    t.string "login"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["login"], name: "index_user_credentials_on_login", unique: true
    t.index ["user_id"], name: "index_user_credentials_on_user_id"
  end

  create_table "user_passwords", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "digest"
    t.datetime "disabled_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_user_passwords_on_user_id"
  end

  create_table "user_sessions", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "disabled_at"
    t.string "refresh_token"
    t.datetime "updated_at", null: false
    t.bigint "user_credential_id", null: false
    t.index ["user_credential_id"], name: "index_user_sessions_on_user_credential_id"
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.date "birth_date"
    t.datetime "blocked_at"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "gender"
    t.string "last_name"
    t.string "middle_name"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "user_credentials", "users", on_delete: :cascade
  add_foreign_key "user_passwords", "users", on_delete: :cascade
  add_foreign_key "user_sessions", "user_credentials", on_delete: :cascade
end
