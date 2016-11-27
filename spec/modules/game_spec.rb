require 'rails_helper'

RSpec.describe Game, type: :module do
  describe 'start_hand' do
    before do
      @room = Room.find(2)
    end
    context '正常系(人間のみの場合)' do
      before do
        @user_1 = FactoryGirl.create(:user)
        @user_2 = FactoryGirl.create(:user)
        @room.users << @user_1
        @room.users << @user_2
        @room.save!
      end
      it 'start_handすると、handクラスが作られる' do
        expect(Game.start_hand(@room.id).kind_of?(Hand)).to eq(true)
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
    context '正常系(CPUが居る場合)' do
      before do
        @cpu_user = FactoryGirl.create(:user, :name=>'cpu_user', :user_type=>User::UT_CPU)
        @user_1 = FactoryGirl.create(:user, :name=>'user_1')
        @user_2 = FactoryGirl.create(:user, :name=>'user_2')
        @room.users << @user_1
        @room.users << @user_2
        @room.save!
      end
      it 'start_handで作られたクラスには、room_usersが入っている cpuが勝手に入れられる.CPUは最後に入っている' do
        hand = Game.start_hand(@room.id)
        expect(hand.users.count).to eq(3)
        expect(hand.users[0].id).to eq(@user_1.id)
        expect(hand.users[1].id).to eq(@user_2.id)
        expect(hand.users[2].id).to eq(@cpu_user.id)
        expect(hand.button_user.id).to eq(@user_1.id)
        expect(hand.tern_user.id).to eq(@user_1.id)
      end
      it 'ユーザーにカードが配られている' do
        hand = Game.start_hand(@room.id)
        expect(hand.hand_users.count).to eq(3)
        expect(hand.hand_users[0].user_hand.count).to eq(2)
        expect(hand.hand_users[1].user_hand.count).to eq(2)
        expect(hand.hand_users[2].user_hand.count).to eq(2)
      end
    end
    context '異常系' do
      before do
        @user_1 = FactoryGirl.create(:user)
        @user_2 = FactoryGirl.create(:user)
        @room.users << @user_1
        @room.users << @user_2
        @room.save!
      end
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
  describe 'is_round_all' do
    before do
    end
    context 'handが存在しない場合' do
      it 'falseが返る' do
        expect(Game.is_rounded_all?(nil)).to eq(false)
      end
    end
    context 'handが存在する場合' do
      it 'handが判定した値が返る' do
        hand_mock = double('hand_mock')
        allow(hand_mock).to receive(:rotated_all?).and_return(true)
        allow(Game).to receive(:_get_hand).and_return(hand_mock)

        expect(Game.is_rounded_all?(hand_mock)).to eq(true)
      end
    end
  end
  describe 'get_next_tern_user' do
    before do
      @user = User.new()
      @hand_mock = double('hand_mock')
    end
    context 'handが存在する場合' do
      before do
        allow(Game).to receive(:_get_hand).and_return(@hand_mock)
      end

      context 'ユーザーがいる場合' do
        before do
          allow(@hand_mock).to receive(:tern_user).and_return(@user)
        end
        it 'ユーザーを返す' do
          expect(Game.get_next_tern_user(0).kind_of?(User)).to eq(true)
          expect(Game.get_next_tern_user(0)).to eq(@user)
        end
      end
      context 'ユーザーがいない場合' do
        before do
          allow(@hand_mock).to receive(:tern_user).and_return(nil)
        end
        it 'nilを返す' do
          expect(Game.get_next_tern_user(0)).to eq(nil)
        end
      end
    end
    context 'handが存在しない場合' do
      before do
      end
      it 'nilを返す' do
        expect(Game.get_next_tern_user(0)).to eq(nil)
      end
    end
  end
  describe 'prompt_tern_action_to_next_user' do
    before do
      @user = User.new(:id=>0)
      allow(Game).to receive(:get_next_tern_user).and_return(@user)
    end
    it "promptするとuserにアクションを促すためのjobが登録される" do
      expect(@user.id.blank?).to eq(false)
      data = {}
      data['hand_id'] = 0
      data['user_id'] = @user.id

      time = Time.current
      travel_to(time) do
        room_id = 9
        assertion = {
          job: PromptTernActionJob,
          args: [room_id, @user]
#          at: (time).to_i
        }
        assert_enqueued_with(assertion) { Game.prompt_tern_action_to_next_user(room_id, data) }
      end
    end
  end
  describe '_add_cpu_user_to_room' do
    before do
      @room = Room.find(2)
    end
    context 'CPUが一人いる場合' do
      before do
        @cpu_user = FactoryGirl.create(:user, :user_type=>User::UT_CPU)
      end
      it '一人追加される' do
        room_users = RoomUser.where(:room_id => 2)
        expect(room_users.count).to eq(0)
        Game.send(:_add_cpu_user_to_room, 2)
        room_users = RoomUser.where(:room_id => 2)
        expect(room_users.count).to eq(1)
        expect(room_users[0].user_id).to eq(@cpu_user.id)
      end
    end
    context 'CPUが一人もいない場合' do
      before do
      end
      it '一人も追加されない' do
        room_users = RoomUser.where(:room_id => 2)
        expect(room_users.count).to eq(0)
        Game.send(:_add_cpu_user_to_room, 2)
        room_users = RoomUser.where(:room_id => 2)
        expect(room_users.count).to eq(0)
      end
    end
    context 'CPUが二人いる場合' do
      before do
        @cpu_user_1 = FactoryGirl.create(:user, :user_type=>User::UT_CPU)
        @cpu_user_2 = FactoryGirl.create(:user, :user_type=>User::UT_CPU)
      end
      it '一人だけ追加される' do
        room_users = RoomUser.where(:room_id => 2)
        expect(room_users.count).to eq(0)
        Game.send(:_add_cpu_user_to_room, 2)
        room_users = RoomUser.where(:room_id => 2)
        expect(room_users.count).to eq(1)
        expect(room_users[0].user_id).to eq(@cpu_user_1.id)
      end
    end
    context 'CPUがすでに部屋に入っている場合' do
      before do
        @cpu_user_1 = FactoryGirl.create(:user, :user_type=>User::UT_CPU)
        @cpu_user_2 = FactoryGirl.create(:user, :user_type=>User::UT_CPU)
        @room.users << @cpu_user_2
      end
      it '入っていたCPUは抜けて、idの一番小さいCPUが入る' do
        room_users = RoomUser.where(:room_id => 2)
        expect(room_users.count).to eq(1)
        expect(room_users[0].user_id).to eq(@cpu_user_2.id)
        Game.send(:_add_cpu_user_to_room, 2)
        room_users = RoomUser.where(:room_id => 2)
        expect(room_users.count).to eq(1)
        expect(room_users[0].user_id).to eq(@cpu_user_1.id)
      end
    end
  end
end