class DlNextBettingRoundService
  def initialize(hand_id)
    @hand_id = hand_id
  end

  def do!()
    hand = Hand.find(@hand_id)
    # ベッティングラウンドを進める
    hand.next_betting_round
    # ユーザーのアクションをリセット
    hand.hand_users.each do |hu|
      hu.last_action_kbn = TernAction::ACT_KBN_NULL
    end
    hand.save!
  end
end

