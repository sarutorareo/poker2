module CpuUser
  # ブラウザを持つクライアント
    # channel
  def tern_action(hand)
    # jsがやっているように、channelにtern_actionを投げる
    hand_user = hand.get_hand_user_from_user_id(self.id)
    TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL, hand.call_chip - hand_user.round_total_chip)
  end

  def is_cpu?
    true
  end
end
