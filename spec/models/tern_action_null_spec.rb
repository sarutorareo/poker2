require 'rails_helper'

RSpec.describe TernActionNull, type: :model do
  before do
    @tern_action_fold = TernActionNull.new
  end
  it 'kbnはnullを返す' do
    expect(@tern_action_fold.kbn).to eq(TernAction::ACT_KBN_NULL)
    expect(@tern_action_fold.kbn_str).to eq('-')
  end
  it 'active?はtrueを返す' do
    expect(@tern_action_fold.active?).to eq(true)
  end
  it 'raise?はfalseを返す' do
    expect(@tern_action_fold.raise?).to eq(false)
  end
end
