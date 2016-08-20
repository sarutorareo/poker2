class CreateRoomUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :room_users do |t|
      t.references :room, null: false
      t.references :user, null: false

      t.timestamps
    end
  end
end
