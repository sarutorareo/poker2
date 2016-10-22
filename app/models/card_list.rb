class CardList < Array
  def self.new_from_str(card_strs)
    new_list = CardList.new
    return new_list if card_strs.blank?
    0.step(card_strs.length-1, 2) do |idx|
      card = Card.new_from_str(card_strs[idx..idx+1])
      new_list << card
    end
    return new_list
  end

  def shuffle!
    self.sort! {|a, b| srand % 2 == 0? -1: +1}
  end

  def sort_val
    self.sort {|a, b| a.val == b.val ? 0 : a.val > b.val ? -1: +1}
  end

  def hicard_than?(other)
    sorted_self = self.sort_val
    sorted_other = other.sort_val
    (0..[sorted_self.count, sorted_other.count].min-1).each do |index|
      return true if sorted_self[index].val > sorted_other[index].val
    end
    return true if sorted_self.count > sorted_other.count
    return false
  end

  def to_s
    result = ""
    self.each do |c|
      result += c.to_s
    end
    return result
  end

  def to_disp_s
    result = ""
    self.each do |c|
      result += c.to_disp_s
    end
    return result
  end
end
