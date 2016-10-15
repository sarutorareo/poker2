require 'rails_helper'

RSpec.describe TernActionCall, type: :model do
  before do
    @tern_action_call = TernActionCall.new(100)
  end
  it 'kbnはcallを返す' do
    expect(@tern_action_call.kbn).to eq(TernAction::ACT_KBN_CALL)
    expect(@tern_action_call.chip).to eq(100)
    expect(@tern_action_call.kbn_str).to eq('call')
  end
end

