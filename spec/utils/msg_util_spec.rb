require 'rails_helper'

RSpec.describe MsgUtil, type: :util do
  describe 'msg_winners' do
    context '特定の一人(tarou)が勝者のとき' do
      before do
        @user_1 = FactoryGirl.create(:user, :name=>"tarou")
        @winners = [@user_1.id]
      end
      it 'その人の名前を使ったメッセージを返す' do
        expect(MsgUtil.msg_winners(0, @winners)).to eq('POT(1): Winner is tarou!')
      end
    end
    context '特定の一人(tarou)が勝者のとき, 配列でなく呼ばれたとき' do
      before do
        @user_1 = FactoryGirl.create(:user, :name=>"tarou")
        @winners = @user_1.id
      end
      it 'その人の名前を使ったメッセージを返す' do
        expect(MsgUtil.msg_winners(1, @winners)).to eq('POT(2): Winner is tarou!')
      end
    end
    context '勝者が一人も居ないとき' do
      before do
        @user_1 = FactoryGirl.create(:user, :name=>"tarou")
        @winners = []
      end
      it 'メッセージを返す' do
        expect(MsgUtil.msg_winners(0, @winners)).to eq('POT(1): No Winner')
      end
    end
    context '勝者が複数人のとき' do
      before do
        @user_1 = FactoryGirl.create(:user, :name=>"tarou")
        @user_2 = FactoryGirl.create(:user, :name=>"jirou")
        @winners = [@user_1.id, @user_2.id]
      end
      it '複数人用のメッセージを返す' do
        expect(MsgUtil.msg_winners(1, @winners)).to eq('POT(2): Winners are tarou, jirou!')
      end
    end
  end
end
