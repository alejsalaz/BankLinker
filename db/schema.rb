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

ActiveRecord::Schema[8.1].define(version: 2026_04_19_204655) do
  create_table "envelopes", force: :cascade do |t|
    t.string "color", default: "slate", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_envelopes_on_name", unique: true
    t.index ["position"], name: "index_envelopes_on_position"
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "description", null: false
    t.integer "envelope_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["envelope_id"], name: "index_transactions_on_envelope_id"
    t.index ["status"], name: "index_transactions_on_status"
  end

  add_foreign_key "transactions", "envelopes"
end
