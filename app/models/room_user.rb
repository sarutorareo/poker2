class RoomUser < ApplicationRecord
  belongs_to :room
  belongs_to :user
  after_create_commit {
  }
  validates :user_id, uniqueness: {
      message: "すでに部屋に入っています",
      scope: [:room_id]
  }
end
