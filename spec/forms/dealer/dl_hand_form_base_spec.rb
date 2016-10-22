require 'rails_helper'

RSpec.describe DlHandFormBase, type: :form do
  describe 'recieve' do
    it 'パラメータを受け取る' do
      data = {}
      data[:hand_id] = 3
      form = DlHandFormBase.new(data)
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
        form = DlHandFormBase.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'hand_idがあるなら' do
      before do
        @data = {}
        @data[:hand_id] = '1'
      end
      it 'valid?=true' do
        form = DlHandFormBase.new(@data)
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
        @data[:hand_id] = 3
      end
      it 'サービスが作られる' do
        form = DlHandFormBase.new(@data)
        expect do
          form.build_service
        end.to raise_error(NotImplementedError)
      end
    end
  end
end

