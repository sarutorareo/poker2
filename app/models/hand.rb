class Hand < ApplicationRecord
  belongs_to :button_user, class_name: "User", foreign_key: "button_user_id"
  belongs_to :tern_user, class_name: "User", foreign_key: "tern_user_id"
  belongs_to :room
  has_many :hand_users
  has_many :users, through: :hand_users

  def create_hand_users( user_ids )
    user_ids.each do | id |
      user = User.find(id)
      self.users << user
    end
    # ジョブを作成
    StartHandBroadcastJob.set(wait: WAIT_TIME_START_HAND_BROAD_CAST_JOB.second).perform_later self.room_id, self.id
  end
end
