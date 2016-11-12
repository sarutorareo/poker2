module CpuUser
  # ブラウザを持つクライアント
    # channel
  def tern_action
    p "###### in tern_action ####"
    # jsがやっているように、channelにtern_actionを投げる
    return TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL, 100)
  end

  def is_cpu?
    return true
  end
end
