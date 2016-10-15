require 'rails_helper'

RSpec.describe DlTernActionForm, type: :form do
  describe 'recieve' do
    it 'パラメータを受け取る' do
      data = {}
      data[:hand_id] = 3
      data[:user_id] = 1
      data[:tern_action] = TernActionRaise.new(100)
      form = DlTernActionForm.new(data)
      expect(form.hand_id).to eq(3)
      expect(form.user_id).to eq(1)
      expect(form.tern_action.kbn).to eq(TernAction::ACT_KBN_RAISE)
      expect(form.tern_action.chip).to eq(100)
    end
  end
  describe 'valid' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: @user_1

      @data = {}
      @data[:hand_id] = @hand.id
      @data[:user_id] = @user_1.id
      @data[:tern_action] = TernActionRaise
    end
    context 'パラメータが空なら' do
      before do
        @data = {}
      end
      it 'valid?=false' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'パラメータにuser_idとaction_kbnとhand_idがあり、tern_userのアクション' do
      before do
      end
      it 'valid?=true' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(true)
      end
    end
    context 'パラメータにuser_idとaction_kbnとhand_idがあるが、tern_userのアクションではない' do
      before do
        @data[:user_id] = @user_2.id
      end
      it 'ターンユーザーでなくても valid?=true' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(true)
      end
    end
    context 'パラメータにhand_idがない' do
      before do
        @data[:hand_id] = nil
      end
      it 'valid?=false' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'パラメータにtern_actionがない' do
      before do
        @data[:tern_action] = nil
      end
      it 'valid?=false' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'パラメータにuser_idがない' do
      before do
        @data[:user_id] = nil
      end
      it 'valid?=false' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'action_kbnが(AKT_KBN_NULL)' do
      before do
        @data[:tern_action] = TernActionNull.new
      end
      it 'valid?=false' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
  end
  describe 'build_service' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @hand = Hand.create! room_id: 1, button_user: @user_1, tern_user: @user_1
      @data = {}
    end
    context 'formに渡すパラメータが正しくない時' do
      before do
      end
      it '例外が発生する' do
        form = DlTernActionForm.new(@data)
        expect do
          form.build_service
        end.to raise_error(ArgumentError)
      end
    end
    context 'formに渡すパラメータが正しい時' do
      before do
        @data[:hand_id] = @hand.id
        @data[:user_id] = @user_1.id
        @data[:tern_action] = TernActionRaise.new(100)
      end
      it 'サービスが作られる' do
        form = DlTernActionForm.new(@data)
        srv = form.build_service
        expect(srv).not_to eq(nil)
      end
    end
  end
end
