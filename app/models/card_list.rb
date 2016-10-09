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

  def to_s
    result = ""
    self.each do |c|
      result += c.to_s
    end
    return result
  end
end
