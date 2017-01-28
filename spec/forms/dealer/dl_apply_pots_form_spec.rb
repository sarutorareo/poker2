require 'rails_helper'

RSpec.describe DlApplyPotsForm, type: :form do
  describe '継承関係をテスト' do
    it 'DlHandFormBaseを継承している' do
      expect(DlApplyPotsForm < DlHandFormBase).to eq(true)
    end
  end
  describe 'build_service' do
    before do
      @data = {}
    end
    context 'formに渡すパラメータが正しい時' do
      before do
        pots = [Pot.new]
        @data[:hand_id] = 3
        @data[:pots] = pots
      end
      it 'valid?=true' do
        form = DlApplyPotsForm.new(@data)
        expect(form.valid?).to eq(true)
      end
      it 'サービスが作られる' do
        form = DlApplyPotsForm.new(@data)
        srv = form.build_service
        expect(srv.kind_of?(DlApplyPotsService)).to eq(true)
      end
    end
    context 'formに渡すパラメータにpotsがないとき' do
      before do
        @data[:hand_id] = 3
      end
      it 'valid?=false' do
        form = DlApplyPotsForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
  end
end

