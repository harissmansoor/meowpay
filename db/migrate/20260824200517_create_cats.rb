class CreateCats < ActiveRecord::Migration[8.1]
  def change
    create_table :cats do |t|
      t.string :name, null: false
      t.integer :treats_balance, null: false, default: 0

      t.timestamps
    end
  end
end
