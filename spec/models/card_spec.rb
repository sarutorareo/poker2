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
      expect{ card = Card.new(4, 3) }.to raise_error(ArgumentError)
    end
    it 'noが範囲外で初期化できない' do
      expect{ card = Card.new(Card::ST_DIA, 14) }.to raise_error(ArgumentError)
    end
  end
  describe 'to_s' do
    it 'Clubの13 文字列表現できる' do
      card = Card.new(Card::ST_CLUB, 13)
      expect(card.to_s).to eq("CK")
    end
    it 'Diaの2 文字列表現できる' do
      card = Card.new(Card::ST_DIA, 2)
      expect(card.to_s).to eq("D2")
    end
    it 'SpadeのA 文字列表現できる' do
      card = Card.new(Card::ST_SPADE, 1)
      expect(card.to_s).to eq("SA")
    end
    it 'Heartの10 文字列表現できる' do
      card = Card.new(Card::ST_HEART, 10)
      expect(card.to_s).to eq("HT")
    end
  end
  describe 'to_disp_s' do
    it 'Clubの13 文字列表現できる' do
      card = Card.new(Card::ST_CLUB, 13)
      expect(card.to_disp_s).to eq("♣K")
    end

  end
  describe 'new_from_str' do
    it 'Heartの10 文字列からカードを作れる' do
      card = Card.new_from_str("HT")
      expect(card.suit).to eq(Card::ST_HEART)
      expect(card.no).to eq(10)
    end
  end
  describe 'to_suit' do
    it '"H"はST_HEART' do
      expect(Card::to_suit("H")).to eq(Card::ST_HEART)
    end
    it '"D"はST_DIA' do
      expect(Card::to_suit("D")).to eq(Card::ST_DIA)
    end
    it '"h"はST_HEART' do
      expect(Card::to_suit("h")).to eq(Card::ST_HEART)
    end
  end
  describe 'to_no' do
    it '"K"は13' do
      expect(Card::to_no("K")).to eq(13)
    end
    it '"5"は5' do
      expect(Card::to_no("5")).to eq(5)
    end
    it '"1"は1' do
      expect(Card::to_no("1")).to eq(1)
    end
    it '"A"は1' do
      expect(Card::to_no("A")).to eq(1)
    end
  end
  describe 'val' do
    before do
      @card_ca = Card.new_from_str("CA")
      @card_ck = Card.new_from_str("CK")
    end
    it 'Aは14' do
      expect(@card_ca.val).to eq(14)
    end
    it 'Kは13' do
      expect(@card_ck.val).to eq(13)
    end
  end
  describe 'comp_val' do
    before do
      @card_ca = Card.new_from_str("CA")
      @card_ck = Card.new_from_str("CK")
      @card_sk = Card.new_from_str("SK")
      @card_s2 = Card.new_from_str("S2")
    end
    it 'A > K' do
      expect(@card_ca.bigger_than?(@card_ck)).to eq(true)
      expect(@card_ca.smaller_than?(@card_ck)).to eq(false)
    end

  end
end
