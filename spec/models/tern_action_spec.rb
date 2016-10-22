require 'rails_helper'

RSpec.describe TernAction, type: :model do
  describe 'new_from_kbn' do
    it 'nullの場合' do
      action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_NULL, 100)
      expect(action.kind_of?(TernActionNull)).to eq(true)
      expect(action.chip).to eq(0)
    end
    it 'foldの場合' do
      action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_FOLD, 100)
      expect(action.kind_of?(TernActionFold)).to eq(true)
      expect(action.chip).to eq(0)
    end
    it 'callの場合' do
      action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL, 100)
      expect(action.kind_of?(TernActionCall)).to eq(true)
      expect(action.chip).to eq(100)
    end
    it 'raiseの場合' do
      action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_RAISE, 100)
      expect(action.kind_of?(TernActionRaise)).to eq(true)
      expect(action.chip).to eq(100)
    end
    it 'call_all_inの場合' do
      action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL_ALL_IN, 100)
      expect(action.kind_of?(TernActionCallAllIn)).to eq(true)
      expect(action.chip).to eq(100)
    end
    it 'raise_all_inの場合' do
      action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_RAISE_ALL_IN, 100)
      expect(action.kind_of?(TernActionRaiseAllIn)).to eq(true)
      expect(action.chip).to eq(100)
    end
  end
  describe 'active' do
    it 'baseはtrue' do
      action = TernAction.new
      expect(action.active?).to eq(true)
    end
  end
end

