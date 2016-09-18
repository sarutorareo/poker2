require 'rails_helper'

RSpec.describe HandUser, type: :model do
  describe 'constrctor' do
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
end
