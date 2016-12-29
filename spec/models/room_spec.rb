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
        ar = @room.get_room_user_ids_sorted_by_user_type_enter_time
        expect(ar.count).to eq(2)
        expect(ar[0].is_a?(Integer)).to eq(true)
      end
    end
    context "ユーザーが一人もいない場合" do
      it "長さ0の配列が返される" do
        ar = @room.get_room_user_ids_sorted_by_user_type_enter_time
        expect(ar.count).to eq(0)
      end
    end
  end
  describe "make_room_users_with_user_type_array user_idと room_user_idとuser_typeを持つ配列を返す" do
    before do
      @cpu_user = FactoryGirl.create(:user, :name=>'cpu_user', :user_type=>User::UT_CPU)
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @room = Room.find(1)
    end
    context "ユーザーが一人のとき" do
      before do
        @room.users << @user1
      end
      it "一人分の(user_id, room_user_id, user_type)を含む構造体の配列が作られる" do
        result = @room.send(:get_room_users_with_user_type_array)
        expect(result.count).to eq(1)
        expect(result[0].user_id).to eq(@user1.id)
        expect(result[0].room_user_id).to eq(@room.room_users[0].id)
        expect(result[0].user_type).to eq(User::UT_HUMAN)
      end
    end
    context "人間一人(user1)のあとに人間一人(user2)を追加したとき" do
      before do
        @room.users << @user1
        @room_user_id_1 = @room.room_users[0].id
        @room.users << @user2
        @room_user_id_2 = @room.room_users[1].id
      end
      it "追加した順に構造体(user_id, room_user_id, user_type)の配列が作られる" do
        result = @room.send(:get_room_users_with_user_type_array)
        expect(result.count).to eq(2)
        expect(result[0].user_id).to eq(@user1.id)
        expect(result[0].room_user_id).to eq(@room_user_id_1)
        expect(result[0].user_type).to eq(User::UT_HUMAN)
        expect(result[1].user_id).to eq(@user2.id)
        expect(result[1].room_user_id).to eq(@room_user_id_2)
        expect(result[1].user_type).to eq(User::UT_HUMAN)
      end
    end
    context "人間一人(user2)のあとに人間一人(user1)を追加したとき" do
      before do
        @room.users << @user2
        @room_user_id_2 = @room.room_users[0].id
        @room.users << @user1
        @room_user_id_1 = @room.room_users[1].id
      end
      it "追加した順に構造体(user_id, room_user_id, user_type)の配列が作られる" do
        result = @room.send(:get_room_users_with_user_type_array)
        expect(result.count).to eq(2)
        expect(result[0].user_id).to eq(@user2.id)
        expect(result[0].room_user_id).to eq(@room_user_id_2)
        expect(result[0].user_type).to eq(User::UT_HUMAN)
        expect(result[1].user_id).to eq(@user1.id)
        expect(result[1].room_user_id).to eq(@room_user_id_1)
        expect(result[1].user_type).to eq(User::UT_HUMAN)
      end
    end
    context "CPU一人のあとに人間２人を追加したとき" do
      before do
        @room.users << @cpu_user
        @room_user_id_cpu = @room.room_users[0].id
        @room.users << @user2
        @room_user_id_2 = @room.room_users[1].id
        @room.users << @user1
        @room_user_id_1 = @room.room_users[2].id
      end
      it "一人分の(user_id, room_user_id, user_type)を含む構造体の配列が作られる" do
        result = @room.send(:get_room_users_with_user_type_array)
        expect(result.count).to eq(3)
        expect(result[0].user_id).to eq(@user2.id)
        expect(result[0].room_user_id).to eq(@room_user_id_2)
        expect(result[0].user_type).to eq(User::UT_HUMAN)
        expect(result[1].user_id).to eq(@user1.id)
        expect(result[1].room_user_id).to eq(@room_user_id_1)
        expect(result[1].user_type).to eq(User::UT_HUMAN)
        expect(result[2].user_id).to eq(@cpu_user.id)
        expect(result[2].room_user_id).to eq(@room_user_id_cpu)
        expect(result[2].user_type).to eq(User::UT_CPU)
      end
    end
  end
end
