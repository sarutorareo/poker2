require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'initialize' do
    it '初期化できる' do
      card = Card.new(Card::ST_HEART, 1)
      expect(card.suit).to eq(Card::ST_HEART)
      expect(card.no).to eq(1)
    end
    it '初期化できる2' do
      card = Card.new(Card::ST_CLUB, 13)
      expect(card.suit).to eq(Card::ST_CLUB)
      expect(card.no).to eq(13)
    end
    it 'スーツが範囲外で初期化できない' do
      expect{ card = Card.new(4, 3) }.to raise_error()
    end
    it 'noが範囲外で初期化できない' do
      expect{ card = Card.new(Card::ST_DIA, 14) }.to raise_error()
    end
  end
end
