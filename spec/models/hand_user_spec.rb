require 'rails_helper'

RSpec.describe HandUser, type: :model do
  describe 'before_create' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_1
    end
    context "一人目を追加した場合" do
      before do
        @hand.users << @user_1
      end
      it "オーダーは1" do
        expect(@hand.hand_users[0].tern_order).to eq(1)
      end
    end
    context "2人目を追加した場合" do
      before do
        @hand.users << @user_1
        @hand.users << @user_2
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
  describe "user_handとuser_hand_str" do
    context 'new直後' do
      it '0枚分のカードを持っている' do
        hand_user = HandUser.new
        expect(hand_user.user_hand.count).to eq(0)
      end
    end
    context 'createしてからsaveしてロードする場合' do
      before do
        @user_1 = FactoryGirl.create(:user)
        @user_2 = FactoryGirl.create(:user)
        @room = Room.find(1)
        @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_1
        @hand.users << @user_1
        @hand.users << @user_2
        @hand.save!
      end
      it 'カードを渡してsaveしてロードすると、渡したカードが復旧する' do
        @hand_user = @hand.hand_users[0]
        @hand_user.user_hand << Card.new(Card::ST_CLUB, 13)
        @hand_user.save!
        @hand_user = HandUser.find(@hand_user.id)
        expect(@hand_user.user_hand_str).to eq('CK')
        expect(@hand_user.user_hand.count).to eq(1)
        expect(@hand_user.user_hand[0].suit).to eq(Card::ST_CLUB)
        expect(@hand_user.user_hand[0].no).to eq(13)
      end
    end
  end
end
