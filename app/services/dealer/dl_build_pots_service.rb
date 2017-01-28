class DlBuildPotsService < DlHandServiceBase
  def initialize(hand_id)
    super(hand_id)
  end

  def do!
    pots = []
    # pots = _makePots(pots, 0)
    hand = Hand.find(@hand_id)
    before_min_chip = 0

    _make_pot(hand, before_min_chip, pots)
  end

  private

  def _get_min_hand_total_chip(hand, before_min_chip)
    min_chip = nil
    hand.hand_users.each do |hu|
      next if hu.hand_total_chip <= before_min_chip
      min_chip = hu.hand_total_chip if min_chip.nil? || hu.hand_total_chip < min_chip
    end
    min_chip
  end

  def _make_pot(hand, before_min_chip, pots)
    min_chip = _get_min_hand_total_chip(hand, before_min_chip)
    return pots if min_chip.nil?

    pot = Pot.new
    hand.hand_users.each do |hu|
      next if hu.hand_total_chip <= before_min_chip
      pot.chip += min_chip - before_min_chip
      next if hu.last_action.fold?
      pot.hand_users << hu
    end
    pots << pot

    _make_pot(hand, min_chip, pots)
  end

end

