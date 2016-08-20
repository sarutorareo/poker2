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
end
