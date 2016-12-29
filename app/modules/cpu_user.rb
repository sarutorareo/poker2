module CpuUser
  # ブラウザを持つクライアント
    # channel
  def tern_action(hand)
    # jsがやっているように、channelにtern_actionを投げる
    TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL, hand.call_chip)
  end

  def is_cpu?
    true
  end
end
