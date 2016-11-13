module Game
  def self.start_hand(room_id)
    # 引数の検証
    raise ArgumentError.new "room_user is blank" if Room.find(room_id).room_users.blank?
    user_id = Room.find(room_id).room_users[0].user_id

    # 新たなハンドを作成する
    hand = _create_new_hand({
      room_id: room_id,
      user_id: user_id
    })

    # 新たなハンドを開始する
    _start_hand(room_id, hand.id)

    # betting_roundを表示する
    _send_betting_round(room_id, hand.id)

    return Hand.find(hand.id)
  end

private
  def self._create_new_hand(data)
    room_id = data[:room_id]
    user_id = data[:user_id]

    button_user = User.find(user_id) 
    room = Room.find(room_id)

    hand = Hand.create! room_id: room.id, button_user: button_user, tern_user: button_user
    hand.start_hand!(room.get_room_user_ids)
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
    srv.do!()

    # 配ったカードをクライアント毎に送る
    hand = Hand.find(hand_id)
    hand.hand_users.each do |hu|
      DealCardsJob.perform_later room_id, hu.user.id, hu.user_hand.to_disp_s
    end
  end

  def self._send_betting_round(room_id, hand_id)
    SendBettingRoundJob.perform_later room_id, Hand.find(hand_id).betting_round_str
  end
end
