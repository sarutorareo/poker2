require 'rails_helper'

RSpec.describe TernActionFold, type: :model do
  before do
    @tern_action_fold = TernActionFold.new
  end
  it 'kbnはfoldを返す' do
    expect(@tern_action_fold.kbn).to eq(TernAction::ACT_KBN_FOLD)
    expect(@tern_action_fold.kbn_str).to eq('fold')
    expect(@tern_action_fold.chip).to eq(0)
  end
  it 'fold?はtrueを返す' do
    expect(@tern_action_fold.fold?).to eq(true)
  end
  it 'raise?はfalseを返す' do
    expect(@tern_action_fold.raise?).to eq(false)
  end
end

