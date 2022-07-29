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

ActiveRecord::Schema[7.0].define(version: 2022_07_28_172947) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "email", null: false
    t.jsonb "customer_keys", default: {}
    t.string "tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "person_id"
    t.index ["person_id"], name: "index_customers_on_person_id"
    t.index ["user_id"], name: "index_customers_on_user_id", unique: true
  end

  create_table "donations", force: :cascade do |t|
    t.bigint "non_profit_id", null: false
    t.bigint "integration_id", null: false
    t.string "blockchain_process_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "value"
    t.index ["integration_id"], name: "index_donations_on_integration_id"
    t.index ["non_profit_id"], name: "index_donations_on_non_profit_id"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "giving_values", force: :cascade do |t|
    t.decimal "value"
    t.integer "currency", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "wallet_address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "person_id"
    t.index ["person_id"], name: "index_guests_on_person_id"
  end

  create_table "integration_wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "public_key"
    t.string "encrypted_private_key"
    t.string "private_key_iv"
    t.bigint "integration_id"
    t.index ["integration_id"], name: "index_integration_wallets_on_integration_id"
  end

  create_table "integrations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.uuid "unique_address", default: -> { "gen_random_uuid()" }, null: false
  end

  create_table "mobility_string_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.string "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_string_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_string_translations_on_keys", unique: true
    t.index ["translatable_type", "key", "value", "locale"], name: "index_mobility_string_translations_on_query_keys"
  end

  create_table "mobility_text_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.text "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_text_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_text_translations_on_keys", unique: true
  end

  create_table "non_profit_impacts", force: :cascade do |t|
    t.bigint "non_profit_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.integer "usd_cents_to_one_impact_unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["non_profit_id"], name: "index_non_profit_impacts_on_non_profit_id"
  end

  create_table "non_profits", force: :cascade do |t|
    t.string "name"
    t.string "wallet_address"
    t.text "impact_description"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
  end

  create_table "offer_gateways", force: :cascade do |t|
    t.bigint "offer_id", null: false
    t.string "external_id"
    t.integer "gateway"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id"], name: "index_offer_gateways_on_offer_id"
  end

  create_table "offers", force: :cascade do |t|
    t.integer "currency"
    t.integer "price_cents"
    t.boolean "subscription"
    t.boolean "active"
    t.integer "position_order"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "person_blockchain_transactions", force: :cascade do |t|
    t.integer "treasure_entry_status", default: 0
    t.string "transaction_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "person_payment_id"
    t.index ["person_payment_id"], name: "index_person_blockchain_transactions_on_person_payment_id"
  end

  create_table "person_payment_fees", force: :cascade do |t|
    t.integer "card_fee_cents"
    t.integer "crypto_fee_cents"
    t.bigint "person_payment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_payment_id"], name: "index_person_payment_fees_on_person_payment_id"
  end

  create_table "person_payments", force: :cascade do |t|
    t.datetime "paid_date"
    t.string "payment_method"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "offer_id"
    t.integer "amount_cents"
    t.uuid "person_id"
    t.index ["offer_id"], name: "index_person_payments_on_offer_id"
    t.index ["person_id"], name: "index_person_payments_on_person_id"
  end

  create_table "ribon_configs", force: :cascade do |t|
    t.integer "default_ticket_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sources", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "integration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id"], name: "index_sources_on_integration_id"
    t.index ["user_id"], name: "index_sources_on_user_id"
  end

  create_table "user_donation_stats", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "last_donation_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_donation_stats_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customers", "people"
  add_foreign_key "donations", "integrations"
  add_foreign_key "donations", "non_profits"
  add_foreign_key "donations", "users"
  add_foreign_key "non_profit_impacts", "non_profits"
  add_foreign_key "offer_gateways", "offers"
  add_foreign_key "person_blockchain_transactions", "person_payments"
  add_foreign_key "person_payment_fees", "person_payments"
  add_foreign_key "person_payments", "offers"
  add_foreign_key "person_payments", "people"
  add_foreign_key "user_donation_stats", "users"
end
