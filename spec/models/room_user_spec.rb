require 'rails_helper'

RSpec.describe RoomUser, type: :model do
  describe "一つの部屋には同一のユーザーは一人だけ" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @room = Room.find(1)
    end
    context '1回目の入室の場合' do
      it 'エラーは起きない' do
        @room.users << @user1
        expect(@room).to be_valid
        expect(@room.errors[:user_id]).not_to be_present
      end
    end
    context '２回目の入室の場合' do
      it 'エラーが発生する' do
        @room.users << @user1
        expect { @room.users << @user1 }.to raise_error { |error|
          expect(error).to be_a(ActiveRecord::RecordInvalid)
        }
      end
    end
    context '異なるユーザー２人目の入室の場合' do
      it 'エラーが発生しない' do
        @room.users << @user1
        @room.users << @user2
        expect(@room).to be_valid
        expect(@room.errors[:user_id]).not_to be_present
      end
    end
  end
  describe "usersとroom_usersのソート順をuser_type, 入室した順にする" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @cpu_user = FactoryGirl.create(:user, :user_type=>1)
      @room = Room.find(1)
    end
    context "cpuユーザーがいない場合" do
      context "1, 2 の順に入室" do
        before do
          @room.users << @user1
          @room.users << @user2
        end
        it "入室した順に並ぶ" do
          expect(@room.room_users[0].user_id).to eq(@user1.id)
          expect(@room.room_users[1].user_id).to eq(@user2.id)
        end
      end
      context "2, 1 の順に入室" do
        before do
          @room.users << @user2
          @room.users << @user1
        end
        it "入室した順に並ぶ" do
          expect(@room.room_users[0].user_id).to eq(@user2.id)
          expect(@room.room_users[1].user_id).to eq(@user1.id)
        end
      end
    end
  end
  describe "保存したらエンキュー" do
    before do
      @user1 = FactoryGirl.create(:user)
      @room = Room.find(1)
    end
    it 'createしたらEnteredBloadcastJobがenqueueされている' do
      time = Time.current
      travel_to(time) do
        assertion = {
          job: BloadcastRoomUsersJob,
          #args: @room_user,
          at: (time + WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB).to_i
        }
        assert_enqueued_with(assertion) { 
          @room.users << @user1 
        }
      end
    end
    it 'destroyしたらEnteredBloadcastJobがenqueueされている' do
      @room.users << @user1

      time = Time.current + 1.hours
      travel_to(time) do
        assertion = {
          job: BloadcastRoomUsersJob,
          #args: @room_user,
          at: (time + WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB).to_i
        }
        assert_enqueued_with(assertion) { 
          @room.users.destroy(@user1)
        }
      end
    end
  end
end
