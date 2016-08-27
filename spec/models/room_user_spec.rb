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
end
