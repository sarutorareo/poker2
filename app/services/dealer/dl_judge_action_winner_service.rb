class DlJudgeActionWinnerService < DlHandServiceBase
  attr_accessor :winner_user_id
  
  def initialize(hand_id)
    super(hand_id)
    self.winner_user_id = nil
  end

  def do!()
    hand = Hand.find(@hand_id)
    self.winner_user_id = nil
    active_users = []
    hand.hand_users.each do |hu|
      if hu.last_action_kbn == TernAction::ACT_KBN_NULL
        return
      end
      if hu.last_action_kbn == TernAction::ACT_KBN_FOLD
        next
      end
      active_users << hu
    end

    if (active_users.count != 1)
      return 
    end

    self.winner_user_id = active_users[0].user_id
  end
end

