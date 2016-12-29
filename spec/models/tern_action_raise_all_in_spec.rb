require 'rails_helper'

RSpec.describe TernActionRaiseAllIn, type: :model do
  before do
    @tern_action_raise_all_in = TernActionRaiseAllIn.new(100)
  end
  it 'kbnはraise_all_inを返す' do
    expect(@tern_action_raise_all_in.kbn).to eq(TernAction::ACT_KBN_RAISE_ALL_IN)
    expect(@tern_action_raise_all_in.chip).to eq(100)
    expect(@tern_action_raise_all_in.kbn_str).to eq('all_in(raise)')
    expect(@tern_action_raise_all_in.active?).to eq(true)
    expect(@tern_action_raise_all_in.raise?).to eq(true)
    expect(@tern_action_raise_all_in.all_in?).to eq(true)
  end
end
