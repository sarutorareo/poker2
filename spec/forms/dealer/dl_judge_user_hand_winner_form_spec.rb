require 'rails_helper'

RSpec.describe DlJudgeUserHandWinnerForm, type: :form do
  describe '継承関係をテスト' do
    it 'DlHandFormBaseを継承している' do
      expect(DlJudgeUserHandWinnerForm < DlHandFormBase).to eq(true)
    end
  end
  describe 'recieve' do
    it 'パラメータを受け取る' do
      data = {}
      data[:hand_id] = 3
      data[:hand_user_ids] = [1, 2]
      form = DlJudgeUserHandWinnerForm.new(data)
      expect(form.hand_id).to eq(3)
      expect(form.hand_user_ids.size).to eq(2)
      expect(form.hand_user_ids[0]).to eq(1)
      expect(form.hand_user_ids[1]).to eq(2)
    end
  end

  describe 'valid' do
    context 'パラメータが空なら' do
      before do
        @data = {}
      end
      it 'valid?=false' do
        form = DlJudgeUserHandWinnerForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'hand_idがあるが、hand_user_idsがないなら' do
      before do
        @data = {}
        @data[:hand_id] = '1'
      end
      it 'valid?=false' do
        form = DlJudgeUserHandWinnerForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'hand_user_idsがあるが、hand_idがないなら' do
      before do
        @data = {}
        @data[:hand_user_ids] = [1]
      end
      it 'valid?=false' do
        form = DlJudgeUserHandWinnerForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'hand_idと、hand_user_idsがあるなら' do
        before do
          @data = {}
          @data[:hand_id] = '1'
          @data[:hand_user_ids] = [1]
        end
      it 'valid?=true' do
        form = DlJudgeUserHandWinnerForm.new(@data)
        expect(form.valid?).to eq(true)
      end
    end
  end
  describe 'build_service' do
    before do
      @data = {}
    end
    context 'formに渡すパラメータが正しい時' do
      before do
        @user_1 = FactoryGirl.create(:user)
        @room = Room.find(1)
        @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_1
        @hand.save!
        @data[:hand_id] = @hand.id
        @data[:hand_user_ids] = [@user_1.id]
      end
      it 'サービスが作られる' do
        form = DlJudgeUserHandWinnerForm.new(@data)
        srv = form.build_service
        expect(srv.kind_of?(DlJudgeUserHandWinnerService)).to eq(true)
      end
    end
  end
end

