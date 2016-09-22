require 'rails_helper'

RSpec.describe DlTernActionForm, type: :form do
  describe 'recieve' do
    it 'パラメータを受け取る' do
      data = {}
      data[:user_id] = 1
      data[:action_kbn] = 2
      form = DlTernActionForm.new(data)
      expect(form.user_id).to eq(1)
      expect(form.action_kbn).to eq(2)
    end
  end
  describe 'valid' do
    before do
      @data = {}
    end
    context 'パラメータが空なら' do
      before do
      end
      it 'valid?=false' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'パラメータにuser_idとaction_kbnがある' do
      before do
        @data[:user_id] = 1
        @data[:action_kbn] = 2
      end
      it 'valid?=true' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(true)
      end
    end
    context 'パラメータにuser_idがあるがaction_kbnがない' do
      before do
        @data[:user_id] = 1
        @data[:action_kbn] = nil
      end
      it 'valid?=true' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'パラメータにuser_idがないaction_kbnはある' do
      before do
        @data[:user_id] = nil
        @data[:action_kbn] = 2
      end
      it 'valid?=true' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
    context 'action_kbnが範囲(NONE, FOLD, CALL, RAISE, ALL_IN)外' do
      before do
        @data[:user_id] = 1
        @data[:action_kbn] = 99
      end
      it 'valid?=true' do
        form = DlTernActionForm.new(@data)
        expect(form.valid?).to eq(false)
      end
    end
  end
  describe 'build_service' do
    before do
      @data = {}
    end
    context do
      before do
        @data[:user_id] = 1
        @data[:action_kbn] = 2
      end
      it 'サービスが作られる' do
        form = DlTernActionForm.new(@data)
        srv = form.build_service
        expect(srv).not_to eq(nil)
      end
    end
  end
end
