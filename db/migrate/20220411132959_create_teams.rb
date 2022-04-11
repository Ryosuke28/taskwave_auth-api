class CreateTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :personal_flag, null: false, default: false

      t.timestamps
    end
  end
end
