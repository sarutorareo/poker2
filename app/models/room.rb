class Room < ApplicationRecord
  has_many :room_users
  has_many :users, through: :room_users

  def get_room_user_ids
    ar = self.users.map { |u| u.id }
    return ar
  end
end
