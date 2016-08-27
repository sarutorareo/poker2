class RoomUser < ApplicationRecord
  belongs_to :room
  belongs_to :user
  after_create_commit {
    EnteredBroadcastJob.set(wait: WAIT_TIME_ENTERED_BROAD_CAST_JOB.second).perform_later self.room_id

  }
  after_destroy_commit {
    EnteredBroadcastJob.set(wait: WAIT_TIME_ENTERED_BROAD_CAST_JOB.second).perform_later self.room_id
  }
  validates :user_id, uniqueness: {
      message: "すでに部屋に入っています",
      scope: [:room_id]
  }
end
