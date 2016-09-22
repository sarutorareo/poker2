require 'rails_helper'

RSpec.describe HandUser, type: :model do
  describe 'before_create' do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
    end
    context "一人目を追加した場合" do
      before do
        @hand.users << @user1
      end
      it "オーダーは1" do
        expect(@hand.hand_users[0].tern_order).to eq(1)
      end
    end
    context "2人目を追加した場合" do
      before do
        @hand.users << @user1
        @hand.users << @user2
      end
      it "オーダーは2" do
        expect(@hand.hand_users[1].tern_order).to eq(2)
      end
    end
  end
  describe '#last_action_str' do
    before do
      @hand_user = HandUser.new
    end
    context 'foldの場合' do
      before do
        @hand_user.last_action_kbn = TernAction::ACT_KBN_FOLD
      end
      it '"fold"が返される' do
        expect(@hand_user.last_action_str).to eq('fold')
      end
    end
    context 'callの場合' do
      before do
        @hand_user.last_action_kbn = TernAction::ACT_KBN_CALL
      end
      it '"call"が返される' do
        expect(@hand_user.last_action_str).to eq('call')
      end
    end
    context 'raiseの場合' do
      before do
        @hand_user.last_action_kbn = TernAction::ACT_KBN_RAISE
      end
      it '"raise"が返される' do
        expect(@hand_user.last_action_str).to eq('raise')
      end
    end
    context 'all_inの場合' do
      before do
        @hand_user.last_action_kbn = TernAction::ACT_KBN_ALL_IN
      end
      it '"all_in"が返される' do
        expect(@hand_user.last_action_str).to eq('all_in')
      end
    end
    context 'nullの場合' do
      before do
        @hand_user.last_action_kbn = nil
      end
      it '"-"が返される' do
        expect(@hand_user.last_action_str).to eq('-')
      end
    end
  end
end
