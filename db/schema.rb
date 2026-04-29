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

ActiveRecord::Schema[7.1].define(version: 2026_04_25_000011) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "evacuation_centers", force: :cascade do |t|
    t.string "name", null: false
    t.string "barangay_name", null: false
    t.string "address"
    t.integer "max_capacity", null: false
    t.integer "current_occupancy", default: 0, null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_name"], name: "index_evacuation_centers_on_barangay_name"
    t.index ["status"], name: "index_evacuation_centers_on_status"
  end

  create_table "evacuation_events", force: :cascade do |t|
    t.string "name", null: false
    t.string "barangay_name"
    t.integer "scope", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.bigint "activated_by_id", null: false
    t.bigint "resolved_by_id"
    t.datetime "activated_at", null: false
    t.datetime "resolved_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "typhoon_name"
    t.integer "households_affected", default: 0, null: false
    t.integer "residents_affected", default: 0, null: false
    t.index ["activated_at"], name: "index_evacuation_events_on_activated_at"
    t.index ["activated_by_id"], name: "index_evacuation_events_on_activated_by_id"
    t.index ["barangay_name"], name: "index_evacuation_events_on_barangay_name"
    t.index ["resolved_by_id"], name: "index_evacuation_events_on_resolved_by_id"
    t.index ["status"], name: "index_evacuation_events_on_status"
  end

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
    t.bigint "evacuation_center_id"
    t.index ["archived_at"], name: "index_households_on_archived_at"
    t.index ["barangay_name"], name: "index_households_on_barangay_name"
    t.index ["evacuation_center_id"], name: "index_households_on_evacuation_center_id"
    t.index ["evacuation_status"], name: "index_households_on_evacuation_status"
  end

  create_table "residents", force: :cascade do |t|
    t.bigint "household_id", null: false
    t.string "full_name", null: false
    t.integer "age"
    t.integer "sex", default: 0, null: false
    t.string "relationship_to_head"
    t.integer "special_needs_category", default: 0, null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_residents_on_archived_at"
    t.index ["full_name"], name: "index_residents_on_full_name"
    t.index ["household_id"], name: "index_residents_on_household_id"
    t.index ["special_needs_category"], name: "index_residents_on_special_needs_category"
  end

  create_table "risk_zones", force: :cascade do |t|
    t.string "name", null: false
    t.string "barangay_name", null: false
    t.integer "risk_level", default: 0, null: false
    t.jsonb "boundary", default: {}, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_name"], name: "index_risk_zones_on_barangay_name"
    t.index ["risk_level"], name: "index_risk_zones_on_risk_level"
  end

  create_table "typhoon_mode_activations", force: :cascade do |t|
    t.bigint "activated_by_id", null: false
    t.bigint "deactivated_by_id"
    t.string "barangay_name"
    t.string "typhoon_name"
    t.datetime "activated_at", null: false
    t.datetime "deactivated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activated_by_id"], name: "index_typhoon_mode_activations_on_activated_by_id"
    t.index ["barangay_name"], name: "index_typhoon_mode_activations_on_barangay_name"
    t.index ["deactivated_at"], name: "index_typhoon_mode_activations_on_deactivated_at"
    t.index ["deactivated_by_id"], name: "index_typhoon_mode_activations_on_deactivated_by_id"
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

  add_foreign_key "evacuation_events", "users", column: "activated_by_id"
  add_foreign_key "evacuation_events", "users", column: "resolved_by_id"
  add_foreign_key "household_status_changes", "households"
  add_foreign_key "household_status_changes", "users"
  add_foreign_key "households", "evacuation_centers"
  add_foreign_key "residents", "households"
  add_foreign_key "typhoon_mode_activations", "users", column: "activated_by_id"
  add_foreign_key "typhoon_mode_activations", "users", column: "deactivated_by_id"
end
