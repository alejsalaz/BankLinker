class RenamePocketsToEnvelopes < ActiveRecord::Migration[8.1]
  def change
    rename_table :pockets, :envelopes
    rename_column :transactions, :pocket_id, :envelope_id
  end
end
