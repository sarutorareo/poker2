class Deck < CardList
  def initialize
    Card::SUITS.each do |suit|
      (1..13).each do |no|
        card = Card.new(suit, no)
        self << card
      end
    end
  end

  def shuffle!
    self.sort! {|a, b| srand % 2 == 0? -1: +1}
  end
end
