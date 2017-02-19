class YakuPair < YakuBase

  attr_accessor :pair_val

  def yaku_val
    2
  end

  def self.is_satisfied_by?(five_card_list)
    five_card_list.each_with_index do |c1, i|
      (i+1..five_card_list.length-1).each do |j|
        return true if c1.no == five_card_list[j].no
      end
    end
    false
  end

protected
  def _compare_same_yaku_to(other_yaku)
    return 1 if self.pair_val > other_yaku.pair_val
    return -1 if self.pair_val < other_yaku.pair_val
    0
  end

  def _after_initialize(five_card_list)
    self.pair_val = 0
    five_card_list.each_with_index do |c1, i|
      (i+1..five_card_list.length-1).each do |j|
        self.pair_val = c1.val if c1.no == five_card_list[j].no
      end
    end
    raise 'pair not exists' if self.pair_val == 0
  end
end
