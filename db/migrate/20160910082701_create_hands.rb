class CreateHands < ActiveRecord::Migration[5.0]
  def change
    create_table :hands do |t|
      t.references :room, null: false
      t.references :user, null: false
      t.integer :bb

      t.timestamps
    end
  end
end
