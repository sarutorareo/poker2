# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    p "############### subscribed"
    room = Room.find(params[:room_id])
    user = User.find(params[:user_id]) unless params[:user_id].blank?
    #roomにユーザーを追加する
    #すでに@user_idが存在する場合はvalidationによりActiveRecord::RecordInvalidが発生する
    begin
      room.users << user unless user.blank?
      room.save
    rescue ActiveRecord::RecordInvalid => ex
      #何もしない
    end
    stream_from "room_channel_#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    p "############### unsubscribed"
    room = Room.find(params[:room_id])
    user = User.find(params[:user_id]) unless params[:user_id].blank?
    room.users.destroy(user) unless params[:user_id].blank?
    room.save
  end

  def speak(data)
    user_name = User.find(data['user_id']).name unless data['user_id'].blank?
    Message.create! content: data['message_content'], room_id: data['room_id'], user_name: user_name
  end

  def pull_user_list(data)
    p "############### pull_user_list"
    RoomUsersBroadcastJob.set(wait: WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB.second).perform_later data['room_id']
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

    # 一周したか判定
    if Hand.find(data['hand_id']).rotated_all?
      Message.create! content: '一周した', room_id: data['room_id'], user_name: 'dealer'
      # 勝者を判定
      action_winner = _judge_action_winner(data)
      if action_winner.blank?
        _next_betting_round(data['room_id'], data['hand_id'])
      else
        _send_winner_message(data['room_id'], action_winner)
      end
    #   srv.apply_pot(action_winners)
    end
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
    df = DlTernActionForm.new( {
        :hand_id => data['hand_id'],
        :user_id => data['user_id'],
        :action_kbn => data['action_kbn'],
        :chip => data['chip']
      })
    srv = df.build_service
    srv.do!()
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
      DealCardsJob.perform_later room_id, hu.user.id, hu.user_hand.to_s
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
    SendBoardJob.perform_later room_id, Hand.find(hand_id).board_str
  end
end
