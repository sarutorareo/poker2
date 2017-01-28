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
      sorted_hand_users = hand.sort_by_bad_position.select{|hu| pot.hand_users.include?(hu)}
      mod = chip % pot.hand_users.size
      sorted_hand_users.each do |hu|
        if mod <= 0
          break
        end
        mod -= 1
        hu.user.chip += 1
      end

      # save
      pot.hand_users.each do |hu|
        hu.user.save!
      end
    end
  end

end

