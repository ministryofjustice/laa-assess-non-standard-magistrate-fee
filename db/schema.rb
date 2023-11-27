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

ActiveRecord::Schema[7.1].define(version: 2023_11_27_112643) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_assignments_on_claim_id", unique: true
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_id", null: false
    t.integer "claim_version"
    t.string "event_type"
    t.uuid "primary_user_id"
    t.uuid "secondary_user_id"
    t.string "linked_type"
    t.string "linked_id"
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_events_on_claim_id"
    t.index ["linked_type", "linked_id"], name: "index_events_on_linked_type_and_linked_id"
    t.index ["primary_user_id"], name: "index_events_on_primary_user_id"
    t.index ["secondary_user_id"], name: "index_events_on_secondary_user_id"
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

  add_foreign_key "assignments", "claims"
  add_foreign_key "assignments", "users"
  add_foreign_key "events", "claims"
  add_foreign_key "events", "users", column: "primary_user_id"
  add_foreign_key "events", "users", column: "secondary_user_id"
end
