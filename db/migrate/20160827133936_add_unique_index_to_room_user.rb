class AddUniqueIndexToRoomUser < ActiveRecord::Migration[5.0]
  def change
    add_index :room_users, [:room_id, :user_id], unique: true
  end
end
