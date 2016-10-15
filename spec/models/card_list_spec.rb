require 'rails_helper'
require 'support/card_support'

RSpec.describe CardList, type: :model do
  describe 'new_from_str' do
    context '空文字列を指定された場合' do
      before do
        @card_list = CardList.new_from_str("")
      end
      it '空のリストができる' do
        expect(@card_list.count).to eq(0)
      end
    end
    context 'nilを指定された場合' do
      before do
        @card_list = CardList.new_from_str(nil)
      end
      it '空のリストができる' do
        expect(@card_list.count).to eq(0)
      end
    end
    context 'カード(DK)が指定されている場合' do
      before do
        @card_list = CardList.new_from_str("DK")
      end
      it 'DKが一枚入ったリストができる' do
        expect(@card_list.count).to eq(1)
        expect(@card_list[0].suit).to eq(Card::ST_DIA)
        expect(@card_list[0].no).to eq(13)
      end
    end
    context 'カード2枚(DKCA)が指定されている場合' do
      before do
        @card_list = CardList.new_from_str("DKCA")
      end
      it 'DKとCAが一枚ずつ入ったリストができる' do
        expect(@card_list.count).to eq(2)
        expect(@card_list[0].suit).to eq(Card::ST_DIA)
        expect(@card_list[0].no).to eq(13)
        expect(@card_list[1].suit).to eq(Card::ST_CLUB)
        expect(@card_list[1].no).to eq(1)
      end
    end
  end
  describe 'shuffle' do
    before do
      @card_list_1 = CardList.new_from_str("")
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
      expect(CardSupport.comp_card_list_order(@card_list_1, @card_list_2)).to eq(false)
    end
  end

  describe 'to_s' do
    before do
      @card_list_1 = CardList.new_from_str("")
      (1..3).each do |no|
        card = Card.new(Card::ST_HEART, no)
        @card_list_1 << card
      end
    end
    it '連続した文字列にする' do
      expect(@card_list_1.to_s).to eq("HAH2H3")
    end
  end
  describe 'to_disp_s' do
    before do
      @card_list_1 = CardList.new_from_str("")
      (1..3).each do |no|
        card = Card.new(Card::ST_HEART, no)
        @card_list_1 << card
      end
    end
    it '連続した文字列にする' do
      expect(@card_list_1.to_disp_s).to eq("♥A♥2♥3")
    end
  end
end
