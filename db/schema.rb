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

ActiveRecord::Schema.define(version: 2020_03_01_210257) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "service_versions", force: :cascade do |t|
    t.string "version", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id", "version"], name: "index_service_versions_on_service_id_and_version", unique: true
    t.index ["service_id"], name: "index_service_versions_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
  end

  create_table "traces", force: :cascade do |t|
    t.jsonb "request", null: false
    t.jsonb "response", null: false
    t.datetime "request_ts", null: false
    t.datetime "response_ts", null: false
    t.bigint "service_version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_ts"], name: "index_traces_on_request_ts"
    t.index ["response_ts"], name: "index_traces_on_response_ts"
    t.index ["service_version_id"], name: "index_traces_on_service_version_id"
  end

  add_foreign_key "service_versions", "services"
  add_foreign_key "traces", "service_versions"
end
