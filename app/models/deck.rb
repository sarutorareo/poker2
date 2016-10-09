class Deck < CardList
  def initialize
    Card::SUITS.each do |suit|
      (1..13).each do |no|
        card = Card.new(suit, no)
        self << card
      end
    end
  end
  def self.new_from_str(str)
    if (str == nil)
      return Deck.new
    else
      return super(str)
    end
  end
end
