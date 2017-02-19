require 'rails_helper'

RSpec.describe YakuBase, type: :model do

  describe 'is_satisfied_by?' do
    it '例外が生成される' do
      expect{YakuBase.is_satisfied_by?(nil)}.to raise_error(RuntimeError, 'must override')
    end
  end
  describe 'compare_to' do
    context 'nilと比較した時' do
      it '1が返る' do
        yaku = YakuBase.new(FiveCardList.new_from_str('SAS2S3S4S5'))
        expect(yaku.compare_to(nil)).to eq(1)
      end
    end
    context 'nil以外と比較した時' do
      it '例外が生成される' do
        yaku1 = YakuBase.new(FiveCardList.new_from_str('SAS2S3S4S5'))
        yaku2 = YakuBase.new(FiveCardList.new_from_str('CAC2C3C4C5'))
        expect{yaku1.compare_to(yaku2)}.to raise_error(RuntimeError, 'must override')
      end
    end
    context 'ペアとハイカードを比較した時' do
      it 'ペアが勝つ' do
        yaku1 = YakuBase.new_from_card_list(FiveCardList.new_from_str('SAS2S3S4D8'))
        yaku2 = YakuBase.new_from_card_list(FiveCardList.new_from_str('CAC2C3C4D2'))
        expect(yaku1.compare_to(yaku2) < 0).to eq(true)
        expect(yaku2.compare_to(yaku1) > 0).to eq(true)
      end
    end
  end
  describe 'new_from_str' do
    context 'なんの役もないとき' do
      it 'ハイカードになる' do
        expect(YakuBase.new_from_str('SAS2S3S4C6').kind_of?(YakuHiCard)).to eq(true)
      end
    end
    context 'ペアがあるとき' do
      it 'ワンペアになる' do
        expect(YakuBase.new_from_str('SAS2S3S4C2').kind_of?(YakuPair)).to eq(true)
      end
    end
  end
end