module Game
  SETTLEMENT_NONE = 0
  SETTLEMENT_ACTION = 1
  SETTLEMENT_HAND = 2

  def self.start_hand(room_id)
    # 引数の検証
    raise ArgumentError.new "room_user is blank" if Room.find(room_id).room_users.blank?
    add_cpu_user=true
    _add_cpu_user_to_room(room_id) if add_cpu_user

    # 新たなハンドを作成する
    hand = _create_new_hand({
      room_id: room_id
    })

    # 新たなハンドを開始する
    _start_hand(room_id, hand.id)

    # betting_roundを表示する
    _send_betting_round(room_id, hand.id)

    return Hand.find(hand.id)
  end

  # ユーザーのアクションを処理する
  def self.tern_action(param)
    room_id = Integer(param.fetch('room_id', nil))
    hand_id = Integer(param.fetch('hand_id', nil))
    user_id = Integer(param.fetch('user_id', nil))
    action_kbn = Integer(param.fetch('action_kbn', nil))
    chip = Integer(param.fetch('chip', 0))

    # ユーザーのアクションを処理する
    ta = _accept_user_action({
           'hand_id' => hand_id,
           'user_id' => user_id,
           'action_kbn' => action_kbn,
           'chip' => chip
         })
    return if ta.nil?

    # raiseが入ったらfold, all_in 以外は再アクション
    if ta.raise?
      _reset_all_user_action_for_raise!(hand_id, user_id)
    end

    # potを計算してクライアントに通知
    pots = _build_pot(room_id, hand_id)

    # 勝者を判定
    settlement, winners = _judge_winners(hand_id)
    # 勝者決まったら
    if winners.present?
      # (ショウダウンの場合)ハンドを見せる , ポットを分配する , クライントに伝える
      _after_hand_settlement_arrived(room_id, settlement, winners, pots)
      return
    end

    # 1周したら次のベッティングラウンドへ
    if is_rounded_all?(hand_id)
      # 次のベッティングラウンドへ
      p "###############_next_betting_round"
      _next_betting_round(room_id, hand_id)
    end

    # 次のユーザーにアクションを促す
    prompt_tern_action_to_next_user(room_id, hand_id)
  rescue => e
    ColorLog.clog e.message
    ColorLog.clog e.backtrace
    raise e
  end

  def self.is_rounded_all?(hand_id)
    hand = _get_hand(hand_id)
    return false if hand.blank?
    return hand.rotated_all?
  end

  def self.prompt_tern_action_to_next_user(room_id, hand_id)
    user = get_next_tern_user(hand_id)
    if user.is_cpu?
      ta = user.tern_action(Hand.find(hand_id))
      data = {}
      data['room_id'] = room_id
      data['hand_id'] = hand_id
      data['user_id'] = user.id
      data['action_kbn'] = ta.kbn
      data['chip'] = ta.chip

      tern_action(data)
    else
      PromptTernActionJob.perform_later room_id, user
    end
  end

  def self.get_next_tern_user(hand_id)
    hand = _get_hand(hand_id)
    return nil if hand.blank?
    return hand.tern_user
  end

private

  def self._dbg_last_action_list(h)
    p '############# in _dbg_last_action_list'
    result = ''
    h.hand_users.each do |hu|
      result += "#{hu.user.name}:#{hu.last_action_str} "
    end
    p "result = #{result}"
    return result
  end

  def self._get_hand(hand_id)
    return Hand.find_by_id(hand_id)
  end

  def self._create_new_hand(data)
    room_id = data[:room_id]
    room = Room.find(room_id)

    user_ids = room.get_room_user_ids_sorted_by_user_type_enter_time
    rais 'no room_user' if user_ids.blank?

    button_user = User.find(user_ids[0])
    hand = Hand.create! room_id: room.id, button_user: button_user, tern_user: button_user
    hand.create_hand_users!(user_ids)
    hand.save!
    return hand
  end

  # 新たなハンドを開始する
  def self._start_hand(room_id, hand_id)
    # カードを配る
    df = DlStartHandForm.new({
        :hand_id => hand_id
      })
    srv = df.build_service
    srv.do!

    # 配ったカードをクライアント毎に送る
    hand = Hand.find(hand_id)
    hand.hand_users.each do |hu|
      DealCardsJob.perform_later room_id, hu.user.id, hu.user_hand.to_disp_s
    end
  end

  # ユーザーのアクションを処理する
  def self._accept_user_action(param)
    data = {}
    data['action_kbn'] = param.fetch('action_kbn', nil)
    data['chip'] = param.fetch('chip', 0)
    data['hand_id'] = param.fetch('hand_id', nil)
    data['user_id'] = param.fetch('user_id', nil)

    ColorLog.clog "############## _accept_user_action"
    ColorLog.clog data
    ta = TernAction.new_from_kbn_and_chip(data['action_kbn'], data['chip'])
    df = DlTernActionForm.new( {
        :hand_id => data['hand_id'],
        :user_id => data['user_id'],
        :tern_action => ta
      })
    srv = df.build_service
    return srv.do!
  end

  # fold, all_in しているユーザーを除いてactionをresetする
  def self._reset_all_user_action_for_raise!(hand_id, user_id)
    hand = _get_hand(hand_id)

    ApplicationRecord.transaction do
      hand.get_hand_users_to_reset_by_raise(user_id).each do |hu|
        hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_NULL)
        hu.save!
      end
      hand.save!
    end
  end

  # 勝者が決まったか判定
  # アクションまたはハンドによる勝者を判定する
  def self._judge_winners(hand_id)
    # 一周してなければ何もしない
    unless is_rounded_all?(hand_id)
      return SETTLEMENT_NONE, nil
    end

    action_winner = _judge_action_winner(hand_id)
    unless action_winner.blank?
      return SETTLEMENT_ACTION, action_winner
    end

    hand = Hand.find(hand_id)
    if hand.betting_round != Hand::BR_RIVER
      return SETTLEMENT_NONE, nil
    end

    # showdown
    return SETTLEMENT_HAND, _judge_user_hand_winner(hand_id)
  end

  # 決着がついたあとの処理
  def self._after_hand_settlement_arrived(room_id, settlement, winners, pots)
    # ショウダウンまでいってたらカードを見せる
    if settlement == SETTLEMENT_HAND then
      # TODO
      # _showdown
    end
    # 勝者を伝える
    _send_winner_message(room_id, winners)
    # ポットを分配
    _apply_pots(room_id, pots)
  end

  def self._send_winner_message(room_id, action_winner)
    Message.create! content: MsgUtil.msg_winners(action_winner), room_id: room_id, user_name: 'dealer'
  end

  def self._next_betting_round(room_id, hand_id)
    # ベッティングラウンドを進める
    df = DlNextBettingRoundForm.new({
        :hand_id => hand_id
      })
    srv = df.build_service
    srv.do!

    _send_betting_round(room_id, hand_id)
    _send_board(room_id, hand_id)
  end

  # アクションによって決まる勝者(全員foldさせた人)を判定する
  def self._judge_action_winner(hand_id)
    p "############# in _judge_action_winner"
    df = DlJudgeActionWinnerForm.new({
        :hand_id => hand_id
      })
    srv = df.build_service
    srv.do!

    p "############# after srv.do!"
    return srv.winner_user_id
  end

  # アクションによって決まる勝者(全員foldさせた人)を判定する
  def self._judge_user_hand_winner(hand_id)
    p "############# in _judge_user_hand_winner"
    df = DlJudgeUserHandWinnerForm.new({
        :hand_id => hand_id
      })
    srv = df.build_service
    srv.do!

    p "############# after srv.do!"
    return srv.winner_user_ids
  end

  def self._send_betting_round(room_id, hand_id)
    BroadcastBettingRoundJob.perform_later room_id, Hand.find(hand_id).betting_round_str
  end

  def self._send_board(room_id, hand_id)
    BroadcastBoardJob.perform_later room_id, Hand.find(hand_id).board.to_disp_s
  end

  def self._add_cpu_user_to_room(room_id)
    room = Room.find_by_id(room_id)
    User.where(:user_type=>User::UT_CPU).order(:id).each do |cpu| 
      room.users.delete(cpu)
    end
    User.where(:user_type=>User::UT_CPU).order(:id).each do |cpu| 
      room.users << cpu
      break
    end
  end

  def self._build_pot(room_id, hand_id)
    df = DlBuildPotsForm.new({
        :hand_id => hand_id
      })
    srv = df.build_service
    pots = srv.do!
    
    BroadcastPotsJob.perform_later room_id, Marshal.dump(pots)
    pots
  end

  def self._apply_pots(room_id, pots)
    # ユーザーのチップにポットを分配
    df = DlApplyPotForm.new({
            :hand_id => hand_id
        })
    srv = df.build_service
    srv.do!
  end
end
