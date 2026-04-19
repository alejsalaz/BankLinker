class RenameIvyCategoriesToCategories < ActiveRecord::Migration[8.1]
  def change
    rename_table :ivy_categories, :categories
    rename_column :transactions, :ivy_category_id, :category_id
  end
end
