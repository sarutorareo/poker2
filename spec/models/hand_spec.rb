require 'rails_helper'

RSpec.describe Hand, type: :model do
  describe "create_hand_users!" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_1.chip = 101
      @user_2 = FactoryGirl.create(:user)
      @user_2.chip = 102
      @room = Room.find(1)
    end
    context "roomにユーザーが二人いる場合" do
      before do
        @room.users << @user_1
        @room.users << @user_2
        button_user = @user_1
        @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      end
      it "二人分hand_userが作られる" do
        @hand.create_hand_users!(@room.get_room_user_ids)
        expect(@hand.hand_users.count).to eq(2)
        # "DBに値が保存されている"
        expect(HandUser.count(:hand_id == @hand.id)).to eq(2)
        # ユーザーのチップが設定されている
        expect(HandUser.find_by_user_id(@user_1.id).chip).to eq(@user_1.chip)
        expect(HandUser.find_by_user_id(@user_2.id).chip).to eq(@user_2.chip)
      end
    end
    context "roomにユーザーが一人もいない場合" do
      before do
        button_user = @user_1
        @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      end
      it "長さ0のhand_userが作られる" do
        @hand.create_hand_users!(@room.get_room_user_ids)
        expect(@hand.hand_users.count).to eq(0)
      end
    end
  end
  describe "get_tern_user_index" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      @button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: @button_user, tern_user: @button_user
    end
    context "user_1, user_2の順に追加" do
      before do
        @hand.users << @user_1
        @hand.users << @user_2
      end
      context "user_1の場合" do 
        before do
          @hand.tern_user = @user_1
        end
        it "インデックス = 0" do
          expect(@hand.get_tern_user_index).to eq(0)
        end
      end
      context "user_2の場合" do 
        before do
          @hand.tern_user = @user_2
        end
        it "インデックス = 1" do
          expect(@hand.get_tern_user_index).to eq(1)
        end
      end
    end
    context "user_2, user_1の順に追加" do
      before do
        @hand.users << @user_2
        @hand.users << @user_1
      end
      context "user_1の場合" do 
        before do
          @hand.tern_user = @user_1
        end
        it "インデックス = 1" do
          expect(@hand.get_tern_user_index).to eq(1)
        end
      end
      context "user_2の場合" do 
        before do
          @hand.tern_user = @user_2
        end
        it "インデックス = 0" do
          expect(@hand.get_tern_user_index).to eq(0)
        end
      end
    end
  end
  describe "rotate_tern" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @user3 = FactoryGirl.create(:user)
      @room = Room.find(1)
      @room.users << @user_1
      @room.users << @user_2
      @room.users << @user3
      @button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: @button_user, tern_user: @button_user
    end
    context "Create直後" do 
      it "ボタンユーザーがターンユーザー" do
        expect(@hand.tern_user.id).to eq(@button_user.id)
        expect(@hand.tern_user.id).to eq(@user_1.id)
      end
    end
    context "start_handをしたら" do 
      it "ボタンユーザーの次の人がターンユーザー" do
        @hand.start_hand!( @room.get_room_user_ids )
        expect(@hand.tern_user.id).to eq(@user_2.id)
      end
    end
    context "start_hand後、rotateをしたら" do 
      it "３人目の人がターンユーザー" do
        @hand.start_hand!( @room.get_room_user_ids )
        @hand.rotate_tern!
        expect(@hand.tern_user.id).to eq(@user3.id)
      end
    end
    context "start_hand後、rotate, さらにrotateをしたら" do 
      it "1人目の人がターンユーザー" do
        @hand.start_hand!( @room.get_room_user_ids )
        @hand.rotate_tern!
        expect(@hand.tern_user.id).to eq(@user3.id)
        @hand.rotate_tern!
        expect(@hand.tern_user.id).to eq(@user_1.id)
      end
    end
  end
  describe 'get_max_order' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
    end
    context "0人しかいないとき" do
      it "max = 0" do
        expect(@hand.get_max_hand_user_order).to eq(0)
      end
    end
    context "1人いるとき" do
      before do
        @hand.users << @user_1
      end
      it "max = 1" do
        expect(@hand.get_max_hand_user_order).to eq(1)
      end
    end
    context "2人いるとき" do
      before do
        @hand.users << @user_1
        @hand.users << @user_2
      end
      it "max = 2" do
        expect(@hand.get_max_hand_user_order).to eq(2)
      end
    end
  end
  describe 'saveされたらjobをenqueue' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
    end
    context "createしてsave" do
      before do
        @hand = Hand.new room_id: @room.id, button_user: @user_1, tern_user: @user_1
      end
      it 'StartHandBloadcastJobがenqueueされている' do
        time = Time.current
        travel_to(time) do
          assertion = {
            job: HandUsersBroadcastJob,
            #args: @room_user,
            at: (time + WAIT_TIME_HAND_USERS_BROAD_CAST_JOB).to_i
          }
          assert_enqueued_with(assertion) { 
            @hand.save!
          }
        end
      end
    end
    context "updateしてsave" do
      before do
        @hand = Hand.new room_id: @room.id, button_user: @user_1, tern_user: @user_1
        @hand.save!
      end
      it 'StartHandBloadcastJobがenqueueされている' do
        time = Time.current
        travel_to(time) do
          assertion = {
            job: HandUsersBroadcastJob,
            #args: @room_user,
            at: (time + WAIT_TIME_HAND_USERS_BROAD_CAST_JOB).to_i
          }
          assert_enqueued_with(assertion) { 
            @hand.tern_user = @user_2
            @hand.save!
          }
        end
      end
    end
  end

  describe 'tern_user?' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: @user_1
    end
    context 'tern_userなら' do
      before do
      end
      it 'trueを返す' do
        expect(@hand.tern_user?(@user_1.id)).to eq(true)
      end
    end
    context 'tern_userではないユーザーのアクションなら' do
      before do
      end
      it 'falseを返す' do
        expect(@hand.tern_user?(@user_2.id)).to eq(false)
      end
    end
  end
  describe "rotated_all?" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: @user_1
      @hand.users << @user_1
      @hand.users << @user_2
    end
    context '全員回ってなかったら' do 
      before do
      end
      it 'falseを返す' do
        expect(@hand.rotated_all?).to eq(false)
      end
    end
    context '全員回ったら' do 
      before do
      end
      it 'trueを返す' do
        @hand.hand_users.each do |hu|
          hu.last_action_kbn = TernAction::ACT_KBN_FOLD
        end
        expect(@hand.rotated_all?).to eq(true)
      end
    end
  end
end
