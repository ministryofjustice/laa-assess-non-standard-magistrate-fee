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

ActiveRecord::Schema[7.1].define(version: 2024_08_01_144635) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_assignments_on_submission_id", unique: true
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "autogrant_limits", force: :cascade do |t|
    t.string "service"
    t.string "unit_type"
    t.date "start_date"
    t.integer "max_units"
    t.decimal "max_rate_london", precision: 10, scale: 2
    t.decimal "max_rate_non_london", precision: 10, scale: 2
    t.integer "travel_hours"
    t.decimal "travel_rate_london", precision: 10, scale: 2
    t.decimal "travel_rate_non_london", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service", "start_date"], name: "index_autogrant_limits_on_service_and_start_date", unique: true
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.integer "submission_version"
    t.string "event_type"
    t.uuid "primary_user_id"
    t.uuid "secondary_user_id"
    t.string "linked_type"
    t.string "linked_id"
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["linked_type", "linked_id"], name: "index_events_on_linked_type_and_linked_id"
    t.index ["primary_user_id"], name: "index_events_on_primary_user_id"
    t.index ["secondary_user_id"], name: "index_events_on_secondary_user_id"
    t.index ["submission_id"], name: "index_events_on_submission_id"
  end

  create_table "submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "state"
    t.string "risk"
    t.integer "current_version"
    t.date "received_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "json_schema_version"
    t.jsonb "data"
    t.datetime "app_store_updated_at"
    t.string "application_type"
    t.datetime "last_updated_at"
    t.index "(((data -> 'defendant'::text) ->> 'first_name'::text)), (((data -> 'defendant'::text) ->> 'last_name'::text))", name: "index_submissions_on_client_name"
    t.index "(((data -> 'firm_office'::text) ->> 'account_number'::text))", name: "index_submissions_on_firm_account_number"
    t.index "(((data -> 'firm_office'::text) ->> 'name'::text))", name: "index_submissions_on_firm_name"
    t.index "((data ->> 'laa_reference'::text))", name: "index_submissions_on_laa_reference"
    t.index "((data ->> 'service_type'::text))", name: "index_submissions_on_service_type"
    t.index "((data ->> 'ufn'::text))", name: "index_submissions_on_ufn"
    t.index "((data ->> 'ufn'::text)), (((data -> 'firm_office'::text) ->> 'account_number'::text))", name: "index_submissions_on_related_applications"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.citext "email"
    t.string "last_name"
    t.string "auth_oid"
    t.string "auth_subject_id"
    t.datetime "last_auth_at"
    t.datetime "first_auth_at"
    t.datetime "deactivated_at"
    t.datetime "invitation_expires_at"
    t.index ["auth_subject_id"], name: "index_users_on_auth_subject_id"
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "assignments", "submissions"
  add_foreign_key "assignments", "users"
  add_foreign_key "events", "submissions"
  add_foreign_key "events", "users", column: "primary_user_id"
  add_foreign_key "events", "users", column: "secondary_user_id"
end
