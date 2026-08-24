class CreateTransfers < ActiveRecord::Migration[8.1]
  def change
    create_table :transfers do |t|
      t.references :sender, null: false, foreign_key: { to_table: :cats }
      t.references :recipient, null: false, foreign_key: { to_table: :cats }
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
