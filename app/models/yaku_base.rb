class YakuBase

  attr_reader :five_card_list

  def self.new_from_str(str)
    five_card_list = FiveCardList.new_from_str(str)
    new_from_card_list(five_card_list)
  end

  def self.new_from_card_list(card_list)
    raise "card_list length is not five but #{card_list.length}" unless card_list.length == 5

    return YakuHiCard.new(card_list) if YakuHiCard.is_satisfied_by?(card_list)

    raise 'invalid params'
  end

  def self.is_satisfied_by?(five_card_list)
    raise 'must override'
  end

  def compare_to(other_yaku)
    return 1 if other_yaku.nil?
    _compare_same_yaku_to(other_yaku)
  end

  def self.get_yaku_value
    0
  end

protected

  def _compare_same_yaku_to(other_yaku)
    raise 'must override'
  end

private

  def initialize(five_card_list)
    @five_card_list = five_card_list
  end

end
