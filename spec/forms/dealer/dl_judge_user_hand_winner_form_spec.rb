require 'rails_helper'

RSpec.describe DlJudgeUserHandWinnerForm, type: :form do
  describe 'recieve' do
    it 'パラメータを受け取る' do
      data = {}
      data[:hand_id] = 3
      form = DlJudgeUserHandWinnerForm.new(data)
      expect(form.hand_id).to eq(3)
    end
  end

  describe 'valid' do
    before do
      @data = {}
      @data[:hand_id] = '1'
    end
    context 'パラメータが空なら' do
      before do
        @data = {}
      end
      it 'valid?=false' do
        form = DlJudgeUserHandWinnerForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'hand_idがあるなら' do
      before do
        @data = {}
        @data[:hand_id] = '1'
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
    context 'formに渡すパラメータが正しくない時' do
      before do
      end
      it '例外が発生する' do
        form = DlJudgeUserHandWinnerForm.new(@data)
        expect do
          form.build_service
        end.to raise_error(ArgumentError)
      end
    end
    context 'formに渡すパラメータが正しい時' do
      before do
        @user_1 = FactoryGirl.create(:user)
        @room = Room.find(1)
        @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_1
        @hand.save!
        @data[:hand_id] = @hand.id
      end
      it 'サービスが作られる' do
        form = DlJudgeUserHandWinnerForm.new(@data)
        srv = form.build_service
        expect(srv.kind_of?(DlJudgeUserHandWinnerService)).to eq(true)
      end
    end
  end
end

