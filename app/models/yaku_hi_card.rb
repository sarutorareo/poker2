class YakuHiCard < YakuBase
  def yaku_val
    1
  end

  def self.is_satisfied_by?(five_card_list)
    true
  end

protected

  def _compare_same_yaku_to(other_yaku)
    return 1 if five_card_list.hicard_than?(other_yaku.five_card_list)
    return -1 if other_yaku.five_card_list.hicard_than?(five_card_list)
    0
  end
end
