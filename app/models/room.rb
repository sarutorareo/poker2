class Room < ApplicationRecord
  has_many :room_users
  has_many :users, through: :room_users

  def get_room_user_ids
    ar = users.order(:id).map { |u| u.id }
    return ar
  end
  def get_room_user_ids_sort_user_type
    ar = users.order(:user_type, :id).map { |u| u.id }
    return ar
  end
end
