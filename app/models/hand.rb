class Hand < ApplicationRecord
  BR_PREFLOP = 0
  BR_FLOP = 1
  BR_TURN = 2
  BR_RIVER = 3

  attr_reader :deck, :board

  belongs_to :button_user, class_name: "User", foreign_key: "button_user_id"
  belongs_to :tern_user, class_name: "User", foreign_key: "tern_user_id"
  belongs_to :room
  has_many :hand_users, ->{ order(:tern_order) }, autosave: true
  has_many :users, through: :hand_users, autosave: true
  after_commit { 
    #hand_user一覧更新 ジョブを作成
    HandUsersBroadcastJob.set(wait: WAIT_TIME_HAND_USERS_BROAD_CAST_JOB.second).perform_later self.room_id, self.id
    #room_user一覧更新 ジョブを作成
    RoomUsersBroadcastJob.set(wait: WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB.second).perform_later self.room_id
  }

  # DB書き込み前に、deck_strをdeckに合わせる
  before_validation {
    self.deck_str = deck.to_s
    self.board_str = board.to_s
  }

  # DB読み込み後に、deckをdeck_strに合わせる
  after_initialize {
    @deck = Deck.new_from_str(self.deck_str)
    @board = CardList.new_from_str(self.board_str)
  }

  def create_hand_users!( user_ids )
    user_ids.each do | id |
      user = User.find(id)
      self.users << user
    end
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

  def betting_round_str
    case self.betting_round
      when 0 then 'preflop'
      when 1 then 'flop'
      when 2 then 'turn'
      when 3 then 'river'
      else raise 'invalid betting_round'
    end
  end

  def next_betting_round
    raise 'betting_round is over' if (self.betting_round == BR_RIVER)
    self.betting_round += 1
  end

  def call_chip
    100
  end

  def min_raise_chip
    200
  end

  def get_hand_users_to_reset_by_raise(uid)
    hand_users.select{|hu| (hu.user_id != uid) && !hu.last_action.fold? && !hu.last_action.all_in?}
  end
end
