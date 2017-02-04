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
        yaku = YakuBase.new(FiveCardList.new_from_str('SAS2S3S4S5'))
        expect{yaku.compare_to(FiveCardList.new_from_str('CAC2C3C4C5'))}.to raise_error(RuntimeError, 'must override')
      end
    end
  end
  describe 'new_from_str' do
    context 'なんの役もないとき' do
      it 'ハイカードになる' do
        expect(YakuBase.new_from_str('SAS2S3S4C6').kind_of?(YakuHiCard)).to eq(true)
      end
    end
  end
end