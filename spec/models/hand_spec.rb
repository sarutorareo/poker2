require 'rails_helper'

RSpec.describe Hand, type: :model do
  describe "create_hand_users" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @room = Room.find(1)
    end
    context "roomにユーザーが二人いる場合" do
      before do
        @room.users << @user1
        @room.users << @user2
        button_user = @user1
        @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      end
      it "二人分hand_userが作られる" do
        @hand.create_hand_users(@room.get_room_user_ids)
        expect(@hand.hand_users.count).to eq(2)
        # "DBに値が保存されている"
        expect(HandUser.count(:hand_id == @hand.id)).to eq(2)
      end
      it 'createしたらStartHandBloadcastJobがenqueueされている' do
        time = Time.current
        travel_to(time) do
          assertion = {
            job: StartHandBroadcastJob,
            #args: @room_user,
            at: (time + WAIT_TIME_START_HAND_BROAD_CAST_JOB).to_i
          }
          assert_enqueued_with(assertion) { 
            @hand.create_hand_users(Array.new)
          }
        end
      end
    end
    context "roomにユーザーが一人もいない場合" do
      before do
        button_user = @user1
        @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      end
      it "長さ0のhand_userが作られる" do
        @hand.create_hand_users(@room.get_room_user_ids)
        expect(@hand.hand_users.count).to eq(0)
      end
    end
  end
 end
