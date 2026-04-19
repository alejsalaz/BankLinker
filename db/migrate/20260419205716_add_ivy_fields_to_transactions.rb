class AddIvyFieldsToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :transaction_type, :integer, default: 0, null: false
    add_column :transactions, :currency, :string, default: "COP", null: false
    add_column :transactions, :title, :string
    add_column :transactions, :receiver, :string
    add_column :transactions, :exchange_currency, :string
    add_column :transactions, :exchange_amount, :decimal, precision: 12, scale: 2
    add_reference :transactions, :ivy_category, foreign_key: true, null: true

    add_index :transactions, :transaction_type
  end
end
