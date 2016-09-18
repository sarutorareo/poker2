class CreateHands < ActiveRecord::Migration[5.0]
  def change
    create_table :hands do |t|
      t.integer :room_id, null: false
      t.integer :button_user_id, null: false
      t.integer :tern_user_id, null: false
      t.integer :bb

      t.timestamps
    end
    add_index :hands, [:room_id]

    add_foreign_key :hands, :rooms, column: "room_id"
    add_foreign_key :hands, :users, column: "button_user_id"
    add_foreign_key :hands, :users, column: "tern_user_id"
  end
end
