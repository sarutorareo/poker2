require 'rails_helper'

RSpec.describe CardList, type: :model do
  describe 'shuffle' do
    def _comp_card_list(list1, list2)
      (0..list1.count-1).each do |idx| 
        suit1 = list1[idx].suit
        suit2 = list2[idx].suit
        no1 = list1[idx].no
        no2 = list2[idx].no
        return false if suit1 != suit2
        return false if no1 != no2
      end
      return true
    end
    before do
      @card_list_1 = CardList.new
      Card::SUITS.each do |suit|
        (1..13).each do |no|
          card = Card.new(suit, no)
          @card_list_1 << card
        end
      end
      @card_list_2 = Marshal.load(Marshal.dump(@card_list_1))
    end
    it 'ランダムにソートされる' do
      @card_list_1.shuffle!
      @card_list_2.shuffle!
      expect(_comp_card_list(@card_list_1, @card_list_2)).to eq(false)
    end
  end
end
