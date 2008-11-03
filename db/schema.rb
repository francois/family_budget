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

ActiveRecord::Schema.define(:version => 20081103020142) do

  create_table "accounts", :force => true do |t|
    t.integer  "family_id",  :limit => 11
    t.string   "name"
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_accounts", :force => true do |t|
    t.integer  "family_id",      :limit => 11
    t.string   "bank_number"
    t.string   "account_number"
    t.integer  "account_id",     :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bank_accounts", ["family_id", "bank_number", "account_number"], :name => "by_family_bank_account", :unique => true

  create_table "budgets", :force => true do |t|
    t.integer  "family_id",  :limit => 11
    t.integer  "account_id", :limit => 11
    t.integer  "year",       :limit => 11
    t.integer  "month",      :limit => 11
    t.decimal  "amount",                   :precision => 9, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "families", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "family_id",                 :limit => 11
    t.boolean  "admin"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "family_id",         :limit => 11
    t.integer  "bank_account_id",   :limit => 11
    t.integer  "debit_account_id",  :limit => 11
    t.integer  "credit_account_id", :limit => 11
    t.date     "posted_on"
    t.decimal  "amount",                          :precision => 12, :scale => 2
    t.string   "name"
    t.string   "memo"
    t.string   "fitid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["family_id", "fitid"], :name => "by_family_fitid", :unique => true
  add_index "transactions", ["family_id", "posted_on"], :name => "by_family_posted"

  create_table "transfers", :force => true do |t|
    t.integer  "family_id",         :limit => 11
    t.date     "posted_on"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "debit_account_id",  :limit => 11
    t.integer  "credit_account_id", :limit => 11
    t.decimal  "amount",                          :precision => 9, :scale => 2
  end

end
