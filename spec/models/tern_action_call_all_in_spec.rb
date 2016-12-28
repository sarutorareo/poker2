require 'rails_helper'

RSpec.describe TernActionCallAllIn, type: :model do
  before do
    @tern_action_call_all_in = TernActionCallAllIn.new(100)
  end
  it 'kbnはcall_all_inを返す' do
    expect(@tern_action_call_all_in.kbn).to eq(TernAction::ACT_KBN_CALL_ALL_IN)
    expect(@tern_action_call_all_in.chip).to eq(100)
    expect(@tern_action_call_all_in.kbn_str).to eq('all_in(call)')
    expect(@tern_action_call_all_in.raise?).to eq(false)
  end
end
