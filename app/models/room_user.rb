class RoomUser < ApplicationRecord
  belongs_to :room
  belongs_to :user
  after_create_commit {
    EnteredBroadcastJob.perform_later self 
  }
end
