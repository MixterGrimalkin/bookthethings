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

ActiveRecord::Schema.define(version: 20191111173811) do

  create_table "availabilities", force: :cascade do |t|
    t.integer "provider_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "repeat_weekly_until"
    t.boolean "all_services"
    t.boolean "all_locations"
    t.boolean "remote_locations"
    t.integer "base_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "availability_locations", force: :cascade do |t|
    t.integer "availability_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "availability_rates", force: :cascade do |t|
    t.integer "availability_id"
    t.integer "rate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "availability_services", force: :cascade do |t|
    t.integer "availability_id"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "customer_id"
    t.integer "provider_id"
    t.integer "location_id"
    t.integer "service_id"
    t.integer "cost"
    t.boolean "confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.text "login_html"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customer_locations", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customer_registrations", force: :cascade do |t|
    t.integer "company_id"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "invite_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.text "street_address"
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provider_locations", force: :cascade do |t|
    t.integer "provider_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provider_services", force: :cascade do |t|
    t.integer "service_id"
    t.integer "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "providers", force: :cascade do |t|
    t.text "description"
    t.string "web_link"
    t.string "photo_url"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "rates", force: :cascade do |t|
    t.integer "cost_amount"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cost_per"
    t.integer "day"
    t.time "start_time"
    t.time "end_time"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "booking_resolution", default: 60
    t.integer "min_length"
    t.integer "max_length"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
  end

end
