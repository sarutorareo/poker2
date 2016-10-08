require 'rails_helper'

RSpec.describe Deck, type: :model do
  describe 'initialize' do
    it '初期化すると52枚のカードができる' do
      deck = Deck.new
      expect(deck.count).to eq(52)
      Card::SUITS.each do |s|
        (1..13).each do |no|
          card = deck.shift
          expect(card.suit).to eq(s)
          expect(card.no).to eq(no)
        end
      end
    end

    it 'シャッフルできる' do
      def _continuous?(deck)
        count = 0
        before_suit = nil
        before_no = 0
        deck.each do |c|
          if before_suit != c.suit 
            before_no = 0
          end
          return false if before_no != (c.no - 1)

          before_suit = c.suit
          before_no = c.no
        end
        return true
      end
      deck = Deck.new
      deck.shuffle!
      expect(_continuous?(deck)).to eq(false)
    end
  end
end
