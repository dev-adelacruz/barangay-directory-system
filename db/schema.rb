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

ActiveRecord::Schema[7.1].define(version: 2026_04_25_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "household_status_changes", force: :cascade do |t|
    t.bigint "household_id", null: false
    t.bigint "user_id", null: false
    t.integer "previous_status"
    t.integer "new_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_household_status_changes_on_created_at"
    t.index ["household_id"], name: "index_household_status_changes_on_household_id"
    t.index ["new_status"], name: "index_household_status_changes_on_new_status"
    t.index ["user_id"], name: "index_household_status_changes_on_user_id"
  end

  create_table "households", force: :cascade do |t|
    t.string "household_head_name", null: false
    t.string "barangay_name", null: false
    t.string "sitio_purok"
    t.integer "member_count", default: 1, null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.integer "evacuation_status", default: 0, null: false
    t.boolean "has_pwd", default: false, null: false
    t.boolean "has_elderly", default: false, null: false
    t.boolean "has_infants", default: false, null: false
    t.boolean "has_pregnant", default: false, null: false
    t.boolean "has_bedridden", default: false, null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_households_on_archived_at"
    t.index ["barangay_name"], name: "index_households_on_barangay_name"
    t.index ["evacuation_status"], name: "index_households_on_evacuation_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.integer "role", default: 0, null: false
    t.string "barangay_name"
    t.string "full_name"
    t.boolean "active", default: true, null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "household_status_changes", "households"
  add_foreign_key "household_status_changes", "users"
end
