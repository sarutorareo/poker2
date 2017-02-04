require 'rails_helper'
require 'support/card_support'

RSpec.describe FiveCardList, type: :model do
  describe '継承関係をテスト' do
    it 'card_listを継承している' do
      expect(FiveCardList < CardList).to eq(true)
    end
  end
  describe 'new_from_str' do
    context '5枚のカードを引数に渡した場合'  do
      it '正常にインスタンス化される' do
        fcl = FiveCardList.new_from_str('SAS2S3S4S5')
        expect(fcl.nil?).to eq(false)
      end
    end
    context '4枚のカードを引数にした場合' do
      it '例外が発生する' do
        expect{FiveCardList.new_from_str('SAS2S3S4')}.to raise_error(RuntimeError, 'card_strs invalid')
      end
    end
    context '6枚のカードを引数にした場合' do
      it '例外が発生する' do
        expect{FiveCardList.new_from_str('SAS2S3S4S5S6')}.to raise_error(RuntimeError, 'card_strs invalid')
      end
    end
  end
end
