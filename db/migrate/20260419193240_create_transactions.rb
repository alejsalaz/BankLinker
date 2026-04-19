class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.date :date, null: false
      t.string :description, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.references :pocket, foreign_key: true, null: true
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :transactions, :status
  end
end
