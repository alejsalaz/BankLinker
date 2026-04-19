class CreateIvyCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :ivy_categories do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :ivy_categories, :name, unique: true
    add_index :ivy_categories, :position
  end
end
