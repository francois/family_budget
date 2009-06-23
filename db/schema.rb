# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081218201104) do

  create_table "accounts", :force => true do |t|
    t.integer  "family_id"
    t.string   "name"
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_accounts", :force => true do |t|
    t.integer  "family_id"
    t.string   "bank_number"
    t.string   "display_account_number"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salted_account_number"
  end

  add_index "bank_accounts", ["family_id"], :name => "by_family"

  create_table "bank_transactions", :force => true do |t|
    t.integer  "family_id"
    t.integer  "bank_account_id"
    t.date     "posted_on"
    t.decimal  "amount",          :precision => 12, :scale => 2
    t.string   "name"
    t.string   "memo"
    t.string   "fitid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "transfer_id"
    t.datetime "ignored_at"
  end

  add_index "bank_transactions", ["family_id", "fitid"], :name => "by_family_fitid", :unique => true
  add_index "bank_transactions", ["family_id", "posted_on"], :name => "by_family_posted"

  create_table "bank_transactions_transfers", :id => false, :force => true do |t|
    t.integer "bank_transaction_id"
    t.integer "transfer_id"
  end

  add_index "bank_transactions_transfers", ["bank_transaction_id", "transfer_id"], :name => "by_bank_transaction_transfer", :unique => true
  add_index "bank_transactions_transfers", ["bank_transaction_id", "transfer_id"], :name => "by_transfer_bank_transaction", :unique => true

  create_table "budgets", :force => true do |t|
    t.integer  "family_id"
    t.integer  "account_id"
    t.decimal  "amount",      :precision => 9, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "starting_on"
  end

  create_table "families", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salt"
  end

  create_table "people", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "family_id"
    t.boolean  "admin"
  end

  create_table "transfers", :force => true do |t|
    t.integer  "family_id"
    t.date     "posted_on"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "debit_account_id"
    t.integer  "credit_account_id"
    t.decimal  "amount",            :precision => 9, :scale => 2
  end

end
