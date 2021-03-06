# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130523121515) do

  create_table "sp500_stocks", :force => true do |t|
    t.string   "symbol"
    t.string   "company_name"
    t.string   "sec_filings"
    t.string   "gics_sector"
    t.string   "gics_sub_industry"
    t.string   "headquarters_city"
    t.date     "sp500_added_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "stock_prices", :force => true do |t|
    t.string   "symbol"
    t.date     "date"
    t.float    "high"
    t.float    "low"
    t.integer  "volume"
    t.float    "open"
    t.float    "close"
    t.float    "adj_close"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.float    "mavg"
    t.float    "stddev"
    t.float    "relative_strength_index"
    t.float    "money_flow_index"
  end

end
