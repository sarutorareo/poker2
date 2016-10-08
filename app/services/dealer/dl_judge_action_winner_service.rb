class DlJudgeActionWinnerService
  attr_accessor :winner_user_id
  
  def initialize(hand_id)
    @hand_id = hand_id
    self.winner_user_id = nil
  end

  def do!()
    hand = Hand.find(@hand_id)
    hand.hand_users.each do |hu|
      if hu.last_action_kbn == TernAction::ACT_KBN_NULL
        self.winner_user_id = nil
        return
      end
      if hu.last_action_kbn == TernAction::ACT_KBN_FOLD
        next
      end
      self.winner_user_id = hu.user_id
      break;
    end
    return false
  end
end

