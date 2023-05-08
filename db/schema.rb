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

ActiveRecord::Schema[7.0].define(version: 2023_05_05_134255) do
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

  create_table "api_keys", force: :cascade do |t|
    t.string "bearer_type", null: false
    t.bigint "bearer_id", null: false
    t.string "token_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bearer_type", "bearer_id"], name: "index_api_keys_on_bearer"
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.string "title"
    t.datetime "published_at", precision: nil
    t.boolean "visible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "link"
    t.integer "language", default: 0
    t.index ["author_id"], name: "index_articles_on_author_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "balance_histories", force: :cascade do |t|
    t.bigint "cause_id", null: false
    t.bigint "pool_id", null: false
    t.decimal "balance"
    t.decimal "amount_donated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cause_id"], name: "index_balance_histories_on_cause_id"
    t.index ["pool_id"], name: "index_balance_histories_on_pool_id"
  end

  create_table "batches", force: :cascade do |t|
    t.string "cid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "amount"
  end

  create_table "big_donors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blockchain_transactions", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "transaction_hash"
    t.bigint "chain_id", null: false
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chain_id"], name: "index_blockchain_transactions_on_chain_id"
    t.index ["owner_type", "owner_id"], name: "index_blockchain_transactions_on_owner"
  end

  create_table "causes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chains", force: :cascade do |t|
    t.string "name"
    t.string "ribon_contract_address"
    t.string "donation_token_contract_address"
    t.integer "chain_id"
    t.string "rpc_url"
    t.string "node_url"
    t.string "symbol_name"
    t.string "currency_name"
    t.string "block_explorer_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gas_fee_url"
    t.string "default_donation_pool_address"
  end

  create_table "contribution_balances", force: :cascade do |t|
    t.bigint "contribution_id", null: false
    t.integer "tickets_balance_cents"
    t.integer "fees_balance_cents"
    t.integer "contribution_increased_amount_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contribution_id"], name: "index_contribution_balances_on_contribution_id"
  end

  create_table "contribution_fees", force: :cascade do |t|
    t.bigint "contribution_id", null: false
    t.bigint "payer_contribution_id", null: false
    t.integer "fee_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payer_contribution_increased_amount_cents"
    t.index ["contribution_id"], name: "index_contribution_fees_on_contribution_id"
    t.index ["payer_contribution_id"], name: "index_contribution_fees_on_payer_contribution_id"
  end

  create_table "contributions", force: :cascade do |t|
    t.string "receiver_type", null: false
    t.bigint "receiver_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "person_payment_id", null: false
    t.integer "generated_fee_cents"
    t.index ["person_payment_id"], name: "index_contributions_on_person_payment_id"
    t.index ["receiver_type", "receiver_id"], name: "index_contributions_on_receiver"
  end

  create_table "crypto_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "wallet_address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "person_id"
    t.index ["person_id"], name: "index_crypto_users_on_person_id"
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

  create_table "donation_batches", force: :cascade do |t|
    t.bigint "donation_id", null: false
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_donation_batches_on_batch_id"
    t.index ["donation_id"], name: "index_donation_batches_on_donation_id"
  end

  create_table "donation_blockchain_transactions", force: :cascade do |t|
    t.bigint "donation_id", null: false
    t.bigint "chain_id", null: false
    t.string "transaction_hash"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chain_id"], name: "index_donation_blockchain_transactions_on_chain_id"
    t.index ["donation_id"], name: "index_donation_blockchain_transactions_on_donation_id"
  end

  create_table "donation_contributions", force: :cascade do |t|
    t.bigint "contribution_id", null: false
    t.bigint "donation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contribution_id"], name: "index_donation_contributions_on_contribution_id"
    t.index ["donation_id"], name: "index_donation_contributions_on_donation_id"
  end

  create_table "donations", force: :cascade do |t|
    t.bigint "non_profit_id", null: false
    t.bigint "integration_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.decimal "value"
    t.string "platform"
    t.index ["integration_id"], name: "index_donations_on_integration_id"
    t.index ["non_profit_id"], name: "index_donations_on_non_profit_id"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "histories", force: :cascade do |t|
    t.bigint "total_donors"
    t.bigint "total_donations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "integration_tasks", force: :cascade do |t|
    t.string "description"
    t.string "link"
    t.string "link_address"
    t.bigint "integration_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id"], name: "index_integration_tasks_on_integration_id"
  end

  create_table "integration_webhooks", force: :cascade do |t|
    t.bigint "integration_id", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id"], name: "index_integration_webhooks_on_integration_id"
  end

  create_table "integrations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "unique_address", default: -> { "gen_random_uuid()" }, null: false
    t.integer "ticket_availability_in_minutes"
    t.integer "status", default: 0
  end

  create_table "legacy_non_profits", force: :cascade do |t|
    t.string "name"
    t.string "logo_url"
    t.integer "impact_cost_ribons"
    t.string "impact_description"
    t.integer "legacy_id"
    t.integer "current_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "impact_cost_usd"
  end

  create_table "legacy_user_impacts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "legacy_non_profit_id", null: false
    t.string "total_impact"
    t.decimal "total_donated_usd"
    t.integer "donations_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_email"
    t.integer "user_legacy_id"
    t.datetime "user_created_at"
    t.index ["legacy_non_profit_id"], name: "index_legacy_user_impacts_on_legacy_non_profit_id"
    t.index ["user_id"], name: "index_legacy_user_impacts_on_user_id"
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
    t.decimal "usd_cents_to_one_impact_unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "impact_description"
    t.string "donor_recipient"
    t.string "measurement_unit"
    t.index ["non_profit_id"], name: "index_non_profit_impacts_on_non_profit_id"
  end

  create_table "non_profit_pools", force: :cascade do |t|
    t.bigint "non_profit_id", null: false
    t.bigint "pool_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["non_profit_id"], name: "index_non_profit_pools_on_non_profit_id"
    t.index ["pool_id"], name: "index_non_profit_pools_on_pool_id"
  end

  create_table "non_profits", force: :cascade do |t|
    t.string "name"
    t.text "impact_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.bigint "cause_id"
    t.index ["cause_id"], name: "index_non_profits_on_cause_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "offer_id"
    t.integer "amount_cents"
    t.uuid "person_id"
    t.integer "status", default: 0
    t.integer "payment_method"
    t.string "external_id"
    t.datetime "refund_date"
    t.bigint "integration_id"
    t.string "receiver_type"
    t.bigint "receiver_id"
    t.string "error_code"
    t.integer "currency"
    t.integer "usd_value_cents"
    t.integer "liquid_value_cents"
    t.string "payer_type"
    t.uuid "payer_id"
    t.index ["integration_id"], name: "index_person_payments_on_integration_id"
    t.index ["offer_id"], name: "index_person_payments_on_offer_id"
    t.index ["payer_type", "payer_id"], name: "index_person_payments_on_payer"
    t.index ["person_id"], name: "index_person_payments_on_person_id"
    t.index ["receiver_type", "receiver_id"], name: "index_person_payments_on_receiver"
  end

  create_table "pool_balances", force: :cascade do |t|
    t.bigint "pool_id", null: false
    t.decimal "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pool_id"], name: "index_pool_balances_on_pool_id"
  end

  create_table "pools", force: :cascade do |t|
    t.string "address"
    t.bigint "token_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "cause_id"
    t.index ["cause_id"], name: "index_pools_on_cause_id"
    t.index ["token_id"], name: "index_pools_on_token_id"
  end

  create_table "ribon_configs", force: :cascade do |t|
    t.decimal "default_ticket_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_chain_id"
    t.decimal "contribution_fee_percentage"
    t.integer "minimum_contribution_chargeable_fee_cents"
  end

  create_table "sources", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "integration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id"], name: "index_sources_on_integration_id"
    t.index ["user_id"], name: "index_sources_on_user_id"
  end

  create_table "stories", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "non_profit_id", null: false
    t.integer "position"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["non_profit_id"], name: "index_stories_on_non_profit_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.integer "decimals"
    t.bigint "chain_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chain_id"], name: "index_tokens_on_chain_id"
  end

  create_table "user_completed_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "task_identifier", null: false
    t.datetime "last_completed_at", null: false
    t.integer "times_completed", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_completed_tasks_on_user_id"
  end

  create_table "user_donation_stats", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "last_donation_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "last_donated_cause"
    t.index ["user_id"], name: "index_user_donation_stats_on_user_id"
  end

  create_table "user_managers", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_user_managers_on_confirmation_token", unique: true
    t.index ["email"], name: "index_user_managers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_user_managers_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_user_managers_on_uid_and_provider", unique: true
  end

  create_table "user_tasks_statistics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "first_completed_all_tasks_at"
    t.integer "streak", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_tasks_statistics_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "language", default: 0
    t.integer "legacy_id"
    t.datetime "deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "utms", force: :cascade do |t|
    t.string "source"
    t.string "medium"
    t.string "campaign"
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trackable_type", "trackable_id"], name: "index_utms_on_trackable"
  end

  create_table "vouchers", force: :cascade do |t|
    t.string "external_id"
    t.bigint "integration_id", null: false
    t.bigint "donation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donation_id"], name: "index_vouchers_on_donation_id"
    t.index ["integration_id"], name: "index_vouchers_on_integration_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.string "public_key"
    t.string "encrypted_private_key"
    t.string "private_key_iv"
    t.integer "status"
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_wallets_on_owner"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "authors"
  add_foreign_key "balance_histories", "causes"
  add_foreign_key "balance_histories", "pools"
  add_foreign_key "blockchain_transactions", "chains"
  add_foreign_key "contribution_balances", "contributions"
  add_foreign_key "contribution_fees", "contributions"
  add_foreign_key "contribution_fees", "contributions", column: "payer_contribution_id"
  add_foreign_key "contributions", "person_payments"
  add_foreign_key "customers", "people"
  add_foreign_key "donation_batches", "batches"
  add_foreign_key "donation_batches", "donations"
  add_foreign_key "donation_blockchain_transactions", "chains"
  add_foreign_key "donation_blockchain_transactions", "donations"
  add_foreign_key "donation_contributions", "contributions"
  add_foreign_key "donation_contributions", "donations"
  add_foreign_key "donations", "integrations"
  add_foreign_key "donations", "non_profits"
  add_foreign_key "donations", "users"
  add_foreign_key "integration_tasks", "integrations"
  add_foreign_key "integration_webhooks", "integrations"
  add_foreign_key "legacy_user_impacts", "legacy_non_profits"
  add_foreign_key "legacy_user_impacts", "users"
  add_foreign_key "non_profit_impacts", "non_profits"
  add_foreign_key "non_profit_pools", "non_profits"
  add_foreign_key "non_profit_pools", "pools"
  add_foreign_key "non_profits", "causes"
  add_foreign_key "offer_gateways", "offers"
  add_foreign_key "person_blockchain_transactions", "person_payments"
  add_foreign_key "person_payment_fees", "person_payments"
  add_foreign_key "person_payments", "integrations"
  add_foreign_key "person_payments", "offers"
  add_foreign_key "person_payments", "people"
  add_foreign_key "pool_balances", "pools"
  add_foreign_key "pools", "causes"
  add_foreign_key "pools", "tokens"
  add_foreign_key "stories", "non_profits"
  add_foreign_key "user_completed_tasks", "users"
  add_foreign_key "user_donation_stats", "users"
  add_foreign_key "user_tasks_statistics", "users"
  add_foreign_key "vouchers", "donations"
  add_foreign_key "vouchers", "integrations"
end
