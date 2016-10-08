class Card
  include ActiveModel::Model

  ST_SPADE = 0
  ST_HEART = 1
  ST_CLUB = 2
  ST_DIA = 3

  SUITS = [ST_SPADE, ST_HEART, ST_CLUB, ST_DIA]

  attr_reader :suit, :no

  def initialize(suit_, no_)
    _check_range_suit(suit_)
    _check_range_no(no_)
    @suit = suit_
    @no = no_
  end

  private
  def _check_range_suit(suit)
    raise "ivalid suit #{suit}" if (!SUITS.include?(suit))
  end
  def _check_range_no(no)
    raise "ivalid no #{no}" if (no < 1 || no > 13)
  end
end
