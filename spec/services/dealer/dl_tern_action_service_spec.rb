require 'rails_helper'

RSpec.describe DlTernActionService, type: :service do
  describe 'do!' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      @hand.users << @user_1
      @hand.users << @user_2
      @hand.save!

      @data = {}
      @data['hand_id'] = 0
      @data['user_id'] = 0
      @data['chip'] = 0
      @data['action_kbn'] = TernAction::ACT_KBN_NULL
    end
    context 'tern_userの場合' do
      context 'user_1がfoldした場合' do
        before do
          @action_kbn = TernAction::ACT_KBN_FOLD
          @data['hand_id'] = @hand.id
          @data['user_id'] = @user_1.id
          @data['action_kbn'] = @action_kbn
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'hand_userのaction_kbnが更新される' do
          expect(@hand.tern_user.id).to eq(@user_1.id)

          @ds.do!()
          @hand = Hand.find(@hand.id)
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
          @hand.save!

          @data['hand_id'] = @hand.id
          @data['user_id'] = @user_2.id
          @data['action_kbn'] = @action_kbn
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'hand_userのaction_kbnが更新される' do
          expect(@hand.tern_user.id).to eq(@user_2.id)

          @ds.do!()
          @hand = Hand.find(@hand.id)
          #user_2のlast_actionが更新されている
          hand_user = @hand.hand_users.where(:user_id => @user_2.id).first
          expect(hand_user.last_action_kbn).to eq(@action_kbn)
          #tern_userはuser_1になる
          expect(@hand.tern_user.id).to eq(@user_1.id)
        end
      end
    end
    context 'tern_userではない場合' do
      context 'user_2がcallした場合' do
        before do
          @action_kbn = TernAction::ACT_KBN_CALL
          @data['hand_id'] = @hand.id
          @data['user_id'] = @user_2.id
          @data['action_kbn'] = @action_kbn
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'hand_userのaction_kbnが更新されない' do
          expect(@hand.tern_user.id).to eq(@user_1.id)

          @ds.do!()
          @hand = Hand.find(@hand.id)
          #user_2のlast_actionが更新されていない
          hand_user = @hand.hand_users.where(:user_id => @user_2.id).first
          expect(hand_user.last_action_kbn).to eq(TernAction::ACT_KBN_NULL)
          #tern_userはuser_1のまま
          expect(@hand.tern_user.id).to eq(@user_1.id)
        end
      end
    end
  end
end
