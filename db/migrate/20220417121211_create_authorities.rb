class CreateAuthorities < ActiveRecord::Migration[6.1]
  def change
    create_table :authorities do |t|
      t.string      :name, null: false
      t.string      :alias
      t.string      :description

      t.timestamps
    end
  end
end
