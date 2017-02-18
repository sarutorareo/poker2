class Card
  include ActiveModel::Model

  ST_SPADE = 0
  ST_HEART = 1
  ST_CLUB = 2
  ST_DIA = 3

  SUITS = [ST_SPADE, ST_HEART, ST_CLUB, ST_DIA]

  attr_reader :suit, :no, :val

  def initialize(suit_, no_)
    _check_range_suit(suit_)
    _check_range_no(no_)
    @suit = suit_
    @no = no_
  end

  def val
    no == 1 ? 14 : no
  end

  def self.new_from_str(str)
    rais ArgumentError, 'bad argument to card' if str.length != 2
    result = Card.new(to_suit(str[0]), to_no(str[1]))
  end

  def to_s
    result = ""
    result += _get_suit_str
    result += _get_no_str
  end

  def to_disp_s
    result = ""
    result += _get_suit_disp_str
    result += _get_no_str
  end

  def self.to_suit(suit_str)
    return case suit_str.upcase
      when 'S' then ST_SPADE
      when 'H' then ST_HEART
      when 'C' then ST_CLUB
      when 'D' then ST_DIA
      else raise 'invalid suit'
    end
  end

  def self.to_no(no_str)
    return case no_str
      when 'A' then 1
      when 'K' then 13
      when 'Q' then 12
      when 'J' then 11
      when 'T' then 10
      else no_str.to_i
    end
  end

  def == other
    return false if other.nil?
    return true if self.suit == other.suit && self.no == other.no
    false
  end

private
  def _check_range_suit(suit)
    raise ArgumentError, "ivalid suit #{suit}" if (!SUITS.include?(suit))
  end
  
  def _check_range_no(no)
    raise ArgumentError, "ivalid no #{no}" if (no < 1 || no > 13)
  end

  def _get_suit_str
    case self.suit
      when ST_SPADE then 'S'
      when ST_HEART then 'H'
      when ST_CLUB then 'C'
      when ST_DIA then 'D'
      else raise 'invalid suit'
    end
  end

  def _get_suit_disp_str
    case self.suit
      when ST_SPADE then '♠'
      when ST_HEART then '♥'
      when ST_CLUB then '♣'
      when ST_DIA then '♦'
      else raise 'invalid suit'
    end
  end

  def _get_no_str
    case self.no
      when 1 then 'A'
      when 13 then 'K'
      when 12 then 'Q'
      when 11 then 'J'
      when 10 then 'T'
      else self.no.to_s
    end
  end
end
