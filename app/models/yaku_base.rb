class YakuBase

  attr_reader :five_card_list

  def self.new_from_str(str)
    five_card_list = FiveCardList.new_from_str(str)
    return YakuHiCard.new(five_card_list) if YakuHiCard.is_satisfied_by?(five_card_list)

    raise 'invalid params'
  end

  def self.is_satisfied_by?(five_card_list)
    raise 'must override'
  end

  def compare_to(other_yaku)
    return 1 if other_yaku.nil?
    _do_compare_to(other_yaku)
  end

  def self.get_yaku_value
    0
  end

protected

  def _do_compare_to(other_yaku)
    raise 'must override'
  end

  def initialize(five_card_list)
    @five_card_list = five_card_list
  end

private
end
