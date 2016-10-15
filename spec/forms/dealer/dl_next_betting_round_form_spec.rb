require 'rails_helper'

RSpec.describe DlNextBettingRoundForm, type: :form do
  describe 'recieve' do
    it 'パラメータを受け取る' do
      data = {}
      data[:hand_id] = 3
      form = DlNextBettingRoundForm.new(data)
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
        form = DlNextBettingRoundForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'hand_idがあるなら' do
      before do
        @data = {}
        @data[:hand_id] = '1'
      end
      it 'valid?=true' do
        form = DlNextBettingRoundForm.new(@data)
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
        form = DlNextBettingRoundForm.new(@data)
        expect do
          form.build_service
        end.to raise_error(ArgumentError)
      end
    end
    context 'formに渡すパラメータが正しい時' do
      before do
        @data[:hand_id] = 3
      end
      it 'サービスが作られる' do
        form = DlNextBettingRoundForm.new(@data)
        srv = form.build_service
        expect(srv).not_to eq(nil)
        expect(srv.kind_of?(DlNextBettingRoundService)).to eq(true)
      end
    end
  end
end

