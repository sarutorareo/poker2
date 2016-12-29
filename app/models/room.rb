class Room < ApplicationRecord
  # room_userのid順（＝入室順)
  has_many :room_users, -> { order(:id) }
  # userのid順（＝ユーザー作成順)
  has_many :users, ->{ order(:id) }, through: :room_users

  RoomUserWithUserType = Struct.new(:user_id, :room_user_id, :user_type)

  def get_room_user_ids_sorted_by_user_type_enter_time
    ar = get_room_users_with_user_type_array.map { |u| u.user_id }
  end

  def get_room_users_with_user_type_array
    ar = []
    self.room_users.each do |ru|
      ar << RoomUserWithUserType.new(ru.user_id, ru.id, ru.user.user_type)
    end
    ar.sort{|a, b| a.room_user_id <=> b.room_user_id}.sort{|a, b| a.user_type <=> b.user_type}
  end

  private

end
