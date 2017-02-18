class YakuPair < YakuBase
  def get_yaku_value
    2
  end

  def self.is_satisfied_by?(five_card_list)
    true
  end

protected

  def _compare_same_yaku_to(other_yaku)
    0
  end
end
