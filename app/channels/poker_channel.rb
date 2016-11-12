# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class PokerChannel < ApplicationCable::Channel
  SETTLEMENT_NONE = 0
  SETTLEMENT_ACTION = 1
  SETTLEMENT_HAND = 2

  def subscribed
    return if params[:room_id].blank?

    p "############### subscribed poker"
    stream_from "poker_channel_#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    p "############### unsubscribed"
  end

  def start_hand(data)
    p "############### start_hand"
    # 新たなハンドを作成する
    hand = _create_new_hand(data)

    # 新たなハンドを開始する
    _start_hand(data['room_id'], hand.id)

    # betting_roundを表示する
    _send_betting_round(data['room_id'], hand.id)
  end

  def tern_action(data)
    p "############### tern_action"
    p data.inspect

    # ユーザーのアクションを処理する
    _accept_user_action(data)

    # 勝者を判定
    if judge_winners(data)
      return
    end

    # 1周したら次のベッティングラウンドへ
    if is_rounded_all?(data['hand_id'])
      # 次のベッティングラウンドへ
      p "###############_next_betting_round"
      _next_betting_round(data['room_id'], data['hand_id'])
    end

    # 次のユーザーにアクションを促す
    prompt_tern_action_to_next_user(data['room_id'], data)
  end

  def prompt_tern_action_to_next_user(room_id, data)
    user = get_next_tern_user(data['hand_id'])
    PrU.cp "##### before PromptTernActionJob.perform_later"
    if user.is_cpu?
      ta = user.tern_action
      data['user_id'] = user.id
      data['action_kbn'] = ta.kbn
      data['chip'] = ta.chip
      tern_action(data)
    else
      PromptTernActionJob.perform_later room_id, user
    end
  end

  def judge_winners(data)
    # 一周してなければ何もしない
    if !is_rounded_all?(data['hand_id'])
      return false
    end

    # 勝者を判定
    settlement, winners = _judge_winners(data)
    # 勝者決まったら
    if winners.present?
      # ハンドで決まったらショウダウン
      if settlement = SETTLEMENT_HAND then
        # TODO
        # _showdown
      end
      # 勝者を伝える
      _send_winner_message(data['room_id'], winners)
      # TODO
      # srv.apply_pot(action_winners)
      return true
    end
  end

  def is_rounded_all?(hand_id)
    hand = get_hand(hand_id)
    return false if hand.blank?
    return hand.rotated_all?
  end

  def get_hand(hand_id)
    return Hand.find_by_id(hand_id)
  end

  def get_next_tern_user(hand_id)
    hand = get_hand(hand_id)
    return nil if hand.blank?
    return hand.tern_user
  end

private

  def _dbg_last_action_list(h)
    p '############# in _dbg_last_action_list'
    result = ''
    h.hand_users.each do |hu|
      result += "#{hu.user.name}:#{hu.last_action_str} "
    end
    p "result = #{result}"
    return result
  end

  # ユーザーのアクションを処理する
  def _accept_user_action(data)
    p "############## before create DLTernActionForm"
    df = DlTernActionForm.new( {
        :hand_id => data['hand_id'],
        :user_id => data['user_id'],
        :tern_action => TernAction.new_from_kbn_and_chip(data['action_kbn'], data['chip'])
      })
    srv = df.build_service
    srv.do!()
  end

  # アクションまたはハンドによる勝者を判定する
  def _judge_winners(data)
    action_winner = _judge_action_winner(data)
    unless action_winner.blank?
      return SETTLEMENT_ACTION, action_winner
    end

    hand = Hand.find(data['hand_id'])
    if hand.betting_round != Hand::BR_RIVER
      return SETTLEMENT_NONE, nil
    end

    # showdown
    return SETTLEMENT_HAND, _judge_user_hand_winner(data)
  end

  # アクションによって決まる勝者(全員foldさせた人)を判定する
  def _judge_action_winner(data)
    p "############# in _judge_action_winner"
    df = DlJudgeActionWinnerForm.new({
        :hand_id => data['hand_id']
      })
    srv = df.build_service
    srv.do!()

    p "############# after srv.do!"
    return srv.winner_user_id
  end

  # アクションによって決まる勝者(全員foldさせた人)を判定する
  def _judge_user_hand_winner(data)
    p "############# in _judge_user_hand_winner"
    df = DlJudgeUserHandWinnerForm.new({
        :hand_id => data['hand_id']
      })
    srv = df.build_service
    srv.do!()

    p "############# after srv.do!"
    return srv.winner_user_ids
  end

  # 新たなハンドを作成する
  def _create_new_hand(data)
    button_user = User.find(data['user_id']) unless data['user_id'].blank?
    room = Room.find(params[:room_id])
    hand = Hand.create! room_id: data['room_id'], button_user: button_user, tern_user: button_user
    hand.start_hand!(room.get_room_user_ids)
    hand.save!
    return hand
  end

  # 新たなハンドを開始する
  def _start_hand(room_id, hand_id)
    # カードを配る
    df = DlStartHandForm.new({
        :hand_id => hand_id
      })
    srv = df.build_service
    srv.do!()

    # 配ったカードをクライアント毎に送る
    hand = Hand.find(hand_id)
    hand.hand_users.each do |hu|
      DealCardsJob.perform_later room_id, hu.user.id, hu.user_hand.to_disp_s
    end
  end

  def _send_winner_message(room_id, action_winner)
    Message.create! content: MsgUtil.msg_winners(action_winner), room_id: room_id, user_name: 'dealer'
  end

  def _next_betting_round(room_id, hand_id)
    # ベッティングラウンドを進める
    df = DlNextBettingRoundForm.new({
        :hand_id => hand_id
      })
    srv = df.build_service
    srv.do!()

    _send_betting_round(room_id, hand_id)
    _send_board(room_id, hand_id)
  end

  def _send_betting_round(room_id, hand_id)
    SendBettingRoundJob.perform_later room_id, Hand.find(hand_id).betting_round_str
  end

  def _send_board(room_id, hand_id)
    SendBoardJob.perform_later room_id, Hand.find(hand_id).board.to_disp_s
  end
end
