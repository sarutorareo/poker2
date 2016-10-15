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
    # ボードにカードを出す
    _set_board(hand)
    hand.save!
  end
private
  def _set_board(hand)
    case hand.betting_round
      when Hand::BR_PREFLOP then return
      when Hand::BR_FLOP then _add_to_board(hand, 3)
      when Hand::BR_TURN then _add_to_board(hand, 1)
      when Hand::BR_RIVER then _add_to_board(hand, 1)
      else raise 'invalid betting_round'
    end
  end

  def _add_to_board(hand, num)
    (1..num).each do 
      hand.board << hand.deck.shift
    end
  end
end

