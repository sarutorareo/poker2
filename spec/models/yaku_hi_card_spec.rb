require 'rails_helper'

RSpec.describe YakuHiCard, type: :model do
  describe '継承関係をテスト' do
    it 'card_listを継承している' do
      expect(YakuHiCard < YakuBase).to eq(true)
    end
  end

  describe 'is_satisfied_by?' do
    it 'なんでも成立する' do
      expect(YakuHiCard.is_satisfied_by?(nil)).to eq(true)
    end
  end
  describe 'compare_to' do
    context 'HiCard同士の場合' do
      context '1枚目で差がつく場合' do
        before do
          @yaku_1 = YakuHiCard.new_from_str('SAS2S3S4S5')
          @yaku_2 = YakuHiCard.new_from_str('CKC2C3C4C5')
        end
        it 'yaku_1が勝つ' do
          expect(@yaku_1.compare_to(@yaku_2)).to eq(1)
          expect(@yaku_2.compare_to(@yaku_1)).to eq(-1)
        end
      end
      context '5枚目で差がつく場合' do
        before do
          @yaku_1 = YakuHiCard.new_from_str('SAS2S3S4S5')
          @yaku_2 = YakuHiCard.new_from_str('D2CAC2C3C4')
        end
        it 'yaku_1が勝つ' do
          expect(@yaku_1.compare_to(@yaku_2)).to eq(1)
          expect(@yaku_2.compare_to(@yaku_1)).to eq(-1)
        end
      end
      context '差がつかない場合' do
        before do
          @yaku_1 = YakuHiCard.new_from_str('SAS2S3S4S5')
          @yaku_2 = YakuHiCard.new_from_str('CAC3C4D5C2')
        end
        it 'yaku_1が勝つ' do
          expect(@yaku_1.compare_to(@yaku_2)).to eq(0)
          expect(@yaku_2.compare_to(@yaku_1)).to eq(0)
        end
      end
    end
  end
end