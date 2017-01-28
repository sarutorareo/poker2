class RoomUser < ApplicationRecord
  belongs_to :room
  belongs_to :user
  after_create_commit {
    BloadcastRoomUsersJob.set(wait: WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB.second).perform_later self.room_id
  }
  after_destroy_commit {
    BloadcastRoomUsersJob.set(wait: WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB.second).perform_later self.room_id
  }
  validates :user_id, uniqueness: {
      message: "すでに部屋に入っています",
      scope: [:room_id]
  }
end
