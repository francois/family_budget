# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "accounts", :force => true do |t|
    t.integer  "family_id"
    t.string   "name"
    t.string   "purpose"
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
  end

  create_table "transfer_members", :force => true do |t|
    t.integer "transfer_id"
    t.integer "account_id"
    t.decimal "debit_amount",  :precision => 9, :scale => 2
    t.decimal "credit_amount", :precision => 9, :scale => 2
  end

  create_table "transfers", :force => true do |t|
    t.integer  "family_id"
    t.date     "posted_on"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
