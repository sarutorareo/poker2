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
    BloadcastHandUsersJob.set(wait: WAIT_TIME_HAND_USERS_BROAD_CAST_JOB.second).perform_later self.room_id, self.id

    #room_user一覧更新 ジョブを作成
    BloadcastRoomUsersJob.set(wait: WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB.second).perform_later self.room_id
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

  def initialize(*)
    super
    self.call_chip = 100
    self.min_raise_chip = 200
  end

  def raise_chip(chip)
    raise "raise short chip" if chip <= 0
    org_call_chip = self.call_chip
    self.call_chip = chip if chip >= self.call_chip
    self.min_raise_chip = self.call_chip + (chip - org_call_chip) if chip >= self.min_raise_chip
  end

  def create_hand_users!( user_ids )
    user_ids.each do | id |
      user = User.find(id)
      self.users << user
    end
  end

  def rotate_tern!
    index = _get_next_tern_user_index(_get_tern_user_index)
    user = User.find(self.hand_users[index].user_id)
    self.tern_user = user
  end

  def get_max_hand_user_order
    if self.hand_users.count == 0
      return 0
    end
    self.hand_users[self.hand_users.count-1].tern_order
  end

  def tern_user?(user_id)
    self.tern_user.id == user_id.to_i
  end

  def rotated_all?
    self.hand_users.each do |hand_user|
      if hand_user.last_action_kbn == TernAction::ACT_KBN_NULL
        return false
      end
    end
    true
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

  def get_hand_users_to_reset_by_raise(uid)
    hand_users.select{|hu| (hu.user_id != uid) && !hu.last_action.fold? && !hu.last_action.all_in?}
  end

  def get_hand_user_from_user_id(user_id)
    hand_users.where(:user_id => user_id).first
  end

private

  def _get_tern_user_index
    index = -1
    self.hand_users.each_with_index do |hu, i|
      if hu.user_id == self.tern_user.id
        index = i
        break
      end
    end
    if index == -1
      raise "no tern_user"
    end
    index
  end

  def _get_next_tern_user_index(current_index)
    index = current_index + 1
    index = 0 if index >= hand_users.count
    while index != current_index do
      break if (!hand_users[index].last_action.fold? && !hand_users[index].last_action.all_in?)
      index = index + 1
      index = 0 if index >= hand_users.count
    end
    index
  end

end
