require 'rails_helper'

RSpec.describe DlBuildPotForm, type: :form do
  describe '継承関係をテスト' do
    it 'DlHandFormBaseを継承している' do
      expect(DlBuildPotForm < DlHandFormBase).to eq(true)
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
        form = DlBuildPotForm.new(@data)
        srv = form.build_service
        expect(srv.kind_of?(DlBuildPotService)).to eq(true)
      end
    end
  end
end

