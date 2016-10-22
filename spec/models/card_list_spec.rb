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
  describe 'sort_val' do
    before do
      @card_list = CardList.new_from_str("")
      @card_list << Card.new(Card::ST_HEART, 3)
      @card_list << Card.new(Card::ST_HEART, 2)
      @card_list << Card.new(Card::ST_HEART, 1)
    end
    it 'カードの値が大きい順にソートされる' do
      sorted = @card_list.sort_val
      expect(sorted[0].no).to eq(1)
      expect(sorted[1].no).to eq(3)
      expect(sorted[2].no).to eq(2)
    end
  end
  describe 'hicard_than?' do
    before do
      @card_list_1 = CardList.new_from_str("")
      @card_list_2 = CardList.new_from_str("")
    end
    context 'A と K' do
      before do
        @card_list_1 << Card.new(Card::ST_HEART, 3)
        @card_list_1 << Card.new(Card::ST_HEART, 1)
        @card_list_1 << Card.new(Card::ST_HEART, 2)
        @card_list_2 << Card.new(Card::ST_HEART, 3)
        @card_list_2 << Card.new(Card::ST_HEART, 13)
        @card_list_2 << Card.new(Card::ST_HEART, 2)
      end
      it ' Aが勝つ ' do
        expect(@card_list_1.hicard_than?(@card_list_2)).to eq(true)
        expect(@card_list_2.hicard_than?(@card_list_1)).to eq(false)
      end
    end
    context '両方空' do
      it ' 引き分け ' do
        expect(@card_list_1.hicard_than?(@card_list_2)).to eq(false)
        expect(@card_list_2.hicard_than?(@card_list_1)).to eq(false)
      end
    end
    context '52 と 35' do
      before do
        @card_list_1 << Card.new(Card::ST_HEART, 5)
        @card_list_1 << Card.new(Card::ST_HEART, 2)
        @card_list_2 << Card.new(Card::ST_HEART, 3)
        @card_list_2 << Card.new(Card::ST_HEART, 5)
      end
      it ' 3(user_2)が勝つ ' do
        expect(@card_list_1.hicard_than?(@card_list_2)).to eq(false)
        expect(@card_list_2.hicard_than?(@card_list_1)).to eq(true)
      end
    end
    context '同じ数字' do
      before do
        @card_list_1 << Card.new(Card::ST_HEART, 3)
        @card_list_1 << Card.new(Card::ST_HEART, 6)
        @card_list_1 << Card.new(Card::ST_HEART, 2)
        @card_list_2 << Card.new(Card::ST_CLUB, 6)
        @card_list_2 << Card.new(Card::ST_CLUB, 3)
        @card_list_2 << Card.new(Card::ST_CLUB, 2)
      end
      it ' 引き分け ' do
        expect(@card_list_1.hicard_than?(@card_list_2)).to eq(false)
        expect(@card_list_2.hicard_than?(@card_list_1)).to eq(false)
      end
    end
    context '同じ数字だけど一枚多い' do
      before do
        @card_list_1 << Card.new(Card::ST_HEART, 3)
        @card_list_1 << Card.new(Card::ST_HEART, 6)
        @card_list_1 << Card.new(Card::ST_HEART, 2)
        @card_list_2 << Card.new(Card::ST_CLUB, 6)
        @card_list_2 << Card.new(Card::ST_CLUB, 3)
        @card_list_2 << Card.new(Card::ST_CLUB, 2)
        @card_list_2 << Card.new(Card::ST_SPADE, 2)
      end
      it ' 多い方がつ ' do
        expect(@card_list_1.hicard_than?(@card_list_2)).to eq(false)
        expect(@card_list_2.hicard_than?(@card_list_1)).to eq(true)
      end
    end
  end
end
