class AddForeignKeysToRoomUsersAndMessages < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :room_users, :rooms, column: "room_id"
    add_foreign_key :room_users, :users, column: "user_id"
    add_foreign_key :messages, :rooms, column: "room_id"
  end
end
