class Hand < ApplicationRecord
  attr_reader :deck

  belongs_to :button_user, class_name: "User", foreign_key: "button_user_id"
  belongs_to :tern_user, class_name: "User", foreign_key: "tern_user_id"
  belongs_to :room
  has_many :hand_users, ->{ order(:tern_order) }, autosave: true
  has_many :users, through: :hand_users, autosave: true
  after_commit { 
    # ジョブを作成
    HandUsersBroadcastJob.set(wait: WAIT_TIME_HAND_USERS_BROAD_CAST_JOB.second).perform_later self.room_id, self.id
  }

  # DB書き込み前に、deck_strをdeckに合わせる
  before_validation {
    self.deck_str = deck.to_s
  }

  # DB読み込み後に、deckをdeck_strに合わせる
  after_initialize {
    @deck = Deck.new_from_str(self.deck_str)
  }

  def create_hand_users!( user_ids )
    user_ids.each do | id |
      user = User.find(id)
      self.users << user
    end
  end

  def start_hand!( user_ids )
    create_hand_users!( user_ids )
  end

  def get_tern_user_index
    index = 0
    self.hand_users.each do |hu|
      if hu.user_id == self.tern_user.id
        break
      end
      index += 1
    end
    #p "index = #{index}, users.count = #{self.users.count} #{users.inspect}"
    if index >= self.users.count
      raise "index >= self.users.count"
    end
    return index
  end

  def rotate_tern!
    index = self.get_tern_user_index
    index += 1
    if index >= self.hand_users.count
      index = 0
    end
    user = User.find(self.hand_users[index].user_id)
    self.tern_user = user
  end

  def get_max_hand_user_order
    if self.hand_users.count == 0
      return 0
    end
    return self.hand_users[self.hand_users.count-1].tern_order
  end

  def tern_user?(user_id)
    return self.tern_user.id == user_id.to_i
  end

  def rotated_all?
    self.hand_users.each do |hand_user|
      if hand_user.last_action_kbn == TernAction::ACT_KBN_NULL
        return false
      end
    end
    return true
  end
end
