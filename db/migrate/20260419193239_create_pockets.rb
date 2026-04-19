class CreatePockets < ActiveRecord::Migration[8.1]
  def change
    create_table :pockets do |t|
      t.string :name, null: false
      t.string :color, null: false, default: "slate"
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :pockets, :name, unique: true
    add_index :pockets, :position
  end
end
