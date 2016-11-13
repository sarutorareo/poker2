require 'rails_helper'

RSpec.describe Game, type: :module do
  describe 'start_hand' do
    before do
      @room = Room.find(2)
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room.users << @user_1
      @room.users << @user_2
      @room.save!
    end
    context '正常系' do
      it 'start_handすると、handクラスが作られる' do
        expect(Game.start_hand(@room.id).kind_of?(Hand)).to eq(true)
      end
      it 'start_handで作られたクラスには、room_usersが入っている' do
        hand = Game.start_hand(@room.id)
        expect(hand.users.count).to eq(2)
        expect(hand.users[0].id).to eq(@user_1.id)
        expect(hand.users[1].id).to eq(@user_2.id)
        expect(hand.button_user.id).to eq(@user_1.id)
        expect(hand.tern_user.id).to eq(@user_1.id)
      end
      it 'ユーザーにカードが配られている' do
        hand = Game.start_hand(@room.id)
        expect(hand.hand_users.count).to eq(2)
        expect(hand.hand_users[0].user_hand.count).to eq(2)
        expect(hand.hand_users[1].user_hand.count).to eq(2)
      end
      it '全てのhandユーザーに通知するジョブが登録されている' do
        time = Time.current
        travel_to(time) do
          assertion = {
            job: DealCardsJob
            #args: [room_id, user_id, user_hand.disp_s],
            #        at: (time).to_i
          }
          assert_enqueued_with(assertion) {
            Game.start_hand(@room.id)
          }
          assert_enqueued_jobs(2, only: DealCardsJob) {
            Game.start_hand(@room.id)
          }
        end
      end
    end
    context '異常系' do
      context 'ユーザーが一人も居ない場合' do
        before do
          @room.users.delete_all
          @room.save!
        end
        it 'start_handすると例外が発生する' do
          expect(@room.users.count).to eq(0)
          expect{Game.start_hand(@room.id)}.to raise_error(ArgumentError, "room_user is blank")
        end
      end
    end
  end
end
