class HandUser < ApplicationRecord
  attr_reader :user_hand, :last_action
  attr_accessor :last_action

  belongs_to :hand
  belongs_to :user
  before_create { 
    _set_order
  }

  # DB書き込み前に、deck_strをdeckに合わせる
  before_validation {
    self.user_hand_str = user_hand.to_s
    self.last_action_kbn = last_action.kbn
    self.last_action_chip = last_action.chip
  }

  # DB読み込み後に、user_handをuser_hand_strに合わせる
  after_initialize {
    @user_hand = CardList.new_from_str(self.user_hand_str)
    @last_action = TernAction.new_from_kbn_and_chip(self.last_action_kbn, self.last_action_chip)
  }

  # 保存された時にクライアントにround_total_chipを伝える
  after_commit {
    #round_total_chip ジョブを作成
    BroadcastRoundTotalChipJob.perform_later hand.room_id, user_id, round_total_chip
  }

  def last_action_kbn_str
    last_action.kbn_str
  end

private
  def _set_order
    max_order = self.hand.get_max_hand_user_order
    self.tern_order = max_order + 1
  end
end
