class DlBuildPotService < DlHandServiceBase
  def initialize(hand_id)
    super(hand_id)
  end

  def do!
    hand = Hand.find(@hand_id)
    pot = Pot.new
    hand.hand_users.each do |hu|
      pot.chip += hu.hand_total_chip
      pot.hand_users << hu unless hu.last_action.fold?
    end
    [pot]
  end

private

  def get_min_hand_total_chip(hand)
    min_chip = nil
    hand.hand_users.each do |hu|
      min_chip = hu.hand_total_chip if min_chip.nil? || hu.hand_total_chip < min_chip
    end
    min_chip
  end
end

