require 'rails_helper'

RSpec.describe DlTernActionService, type: :service do
  describe 'user_action' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      @hand.users << @user_1
      @hand.users << @user_2

      data = {}
      df = DlTernActionForm.new(data)
      @ds = df.build_service
    end
    context 'user_1がfoldした場合' do
      before do
        @action_kbn = TernAction::ACT_KBN_FOLD
      end
      it 'hand_userのaction_kbnが更新される' do
        expect(@hand.tern_user.id).to eq(@user_1.id)

        @ds.user_action(@hand, @user_1.id, @action_kbn)
        #user_1のlast_actionが更新されている
        hand_user = @hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.last_action_kbn).to eq(@action_kbn)
        #tern_userはuser_2になる
        expect(@hand.tern_user.id).to eq(@user_2.id)
      end
    end
    context 'user_2がcallした場合' do
      before do
        @action_kbn = TernAction::ACT_KBN_CALL
        @hand.tern_user = @user_2
      end
      it 'hand_userのaction_kbnが更新される' do
        expect(@hand.tern_user.id).to eq(@user_2.id)

        @ds.user_action(@hand, @user_2.id, @action_kbn)
        #user_2のlast_actionが更新されている
        hand_user = @hand.hand_users.where(:user_id => @user_2.id).first
        expect(hand_user.last_action_kbn).to eq(@action_kbn)
        #tern_userはuser_1になる
        expect(@hand.tern_user.id).to eq(@user_1.id)
      end
    end
  end
end
