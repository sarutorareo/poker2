class DlApplyPotsService < DlHandServiceBase
  def initialize(hand_id, pots)
    super(hand_id)
    @pots = pots
  end

  def do!
    hand = Hand.find(@hand_id)
    _apply_pots(hand, @pots)
  end

  private

  def _apply_pots(hand, pots)
    pots.each do |pot|
      # 端数を除いた分を配る
      pot.hand_users.each do |hu|
        hu.user.chip += pot.chip / pot.hand_users.size
      end

      # 端数を配る
      worst_position_user_id = hand.sort_hand_users_by_bad_position.select{|hu| pot.hand_users.include?(hu)}.first.user_id
      worst_position_user = pot.hand_users.select{|hu| hu.user_id == worst_position_user_id}.first

      mod = pot.chip % pot.hand_users.size
      worst_position_user.user.chip += mod

      # save
      pot.hand_users.each do |hu|
        hu.user.save!
      end
      # 間接的に BroadcastRoomUsersJobを呼び出すためにhand.save!
      hand.save!
    end
  end

end

