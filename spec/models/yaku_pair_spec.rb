require 'rails_helper'

RSpec.describe YakuPair, type: :model do
  describe '継承関係をテスト' do
    it 'card_listを継承している' do
      expect(YakuPair < YakuBase).to eq(true)
    end
  end

  describe 'is_satisfied_by?' do
    it 'ペアがあるとき⇛true' do
      expect(YakuPair.is_satisfied_by?(FiveCardList.new_from_str'SACAD2D3D8')).to eq(true)
    end
    it 'ペアがないとき⇛true' do
      expect(YakuPair.is_satisfied_by?(FiveCardList.new_from_str'SAC9D2D3D8')).to eq(false)
    end
  end
  describe 'pair_value' do
    context 'Aのとき' do
      before do
        @yaku_1 = YakuPair.new_from_str('SACAS3S4D8')
      end
      it '14' do
        expect(@yaku_1.pair_val).to eq(14)
      end
    end
    context '8のとき' do
      before do
        @yaku_1 = YakuPair.new_from_str('SAC8S3S4D8')
      end
      it '8' do
        expect(@yaku_1.pair_val).to eq(8)
      end
    end
  end

  describe 'compare_to' do
    context '差がつく場合' do
      before do
        @yaku_1 = YakuPair.new_from_str('SASAS3S4D8')
        @yaku_2 = YakuPair.new_from_str('CKDKC4D5C2')
      end
      it 'yaku_1が勝つ' do
        expect(@yaku_1.kind_of?(YakuPair)).to eq(true)
        expect(@yaku_2.kind_of?(YakuPair)).to eq(true)
        expect(@yaku_1.compare_to(@yaku_2)).to eq(1)
        expect(@yaku_2.compare_to(@yaku_1)).to eq(-1)
      end
    end
  end
  context '差がつかない場合' do
    before do
      @yaku_1 = YakuPair.new_from_str('SASAS3S4D8')
      @yaku_2 = YakuPair.new_from_str('CQDKC4DACA')
    end
    it 'yaku_1が勝つ' do
      expect(@yaku_1.compare_to(@yaku_2)).to eq(0)
      expect(@yaku_2.compare_to(@yaku_1)).to eq(0)
    end
  end
end