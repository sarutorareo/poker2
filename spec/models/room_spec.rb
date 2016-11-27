require 'rails_helper'

RSpec.describe Room, type: :model do
  before do
  end
  it 'room 1' do
    expect(Room.where(:id => 0).blank? ).to eq(true)
    expect(Room.find(1) != nil).to eq(true)
  end
  describe 'enter' do
    before do
      @room = Room.find(1)
      @user = FactoryGirl.create(:user, {:name=>'user1'})
    end
    it 'ユーザーがroomに入ることができる' do
      expect(@room.users.count).to eq(0)
      expect(RoomUser.count).to eq(0)
      expect(@user.rooms.count).to eq(0)
      @room.users << @user
      expect(@room.users.count).to eq(1)
      expect(RoomUser.count).to eq(1)
      expect(@user.rooms.count).to eq(1)
    end
  end
  describe "get_room_user_ids ルームユーザーのid配列を取得する" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @room = Room.find(1)
    end
    context "ユーザーが二人いる場合" do
      before do
        @room.users << @user1
        @room.users << @user2
      end
      it "二人分のid配列が返される" do
        ar = @room.get_room_user_ids
        expect(ar.count).to eq(2)
        expect(ar[0].is_a?(Integer)).to eq(true)
      end
    end
    context "ユーザーが一人もいない場合" do
      it "長さ0の配列が返される" do
        ar = @room.get_room_user_ids
        expect(ar.count).to eq(0)
      end
    end
  end
  describe "get_room_user_ids_sort_user_type ルームユーザーのid配列を取得する。CPUユーザーは、人間ユーザーよりも後に返される" do
    before do
      @cpu_user = FactoryGirl.create(:user, :name=>'cpu_user', :user_type=>User::UT_CPU)
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @room = Room.find(1)
    end
    context "CPUの方が先にルームに入った場合" do
      before do
        @room.users << @cpu_user
        @room.users << @user2
        @room.users << @user1
      end
      it "人間の方が先に並べられる" do
        ar = @room.get_room_user_ids_sort_user_type
        expect(ar.count).to eq(3)
        expect(ar[0]).to eq(@user1.id)
        expect(ar[1]).to eq(@user2.id)
        expect(ar[2]).to eq(@cpu_user.id)
      end
    end
    context "ユーザーが一人もいない場合" do
      it "長さ0の配列が返される" do
        ar = @room.get_room_user_ids
        expect(ar.count).to eq(0)
      end
    end
  end
end
