class FiveCardList < CardList

protected

  def self._check_params(card_strs)
    raise 'card_strs invalid' if card_strs.length != 10
  end
end
