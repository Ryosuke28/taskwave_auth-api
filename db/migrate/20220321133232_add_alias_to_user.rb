class AddAliasToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string, null: false
    add_column :users, :alias, :string

    add_index :users, :name, unique: true
  end
end
