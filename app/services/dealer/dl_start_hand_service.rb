class DlStartHandService
  
  def initialize(hand_id)
    @hand_id = hand_id
  end

  def do!()
    hand = Hand.find(@hand_id)
    # シャッフルする
    (1..10).each do
      hand.deck.shuffle!
    end
    # TODO burnする
   
    # カードを配る
    (1..2).each do
      hand.hand_users.each do |hu|
        hu.user_hand << hand.deck.shift
      end
    end
    ApplicationRecord.transaction do
      hand.save!
      hand.hand_users.each do |hu|
        hu.save!
      end
    end
  end
end

