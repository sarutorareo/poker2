require 'rails_helper'

RSpec.describe TernActionRaise, type: :model do
  before do
    @tern_action_raise = TernActionRaise.new(100)
  end
  it 'kbnはraiseを返す' do
    expect(@tern_action_raise.kbn).to eq(TernAction::ACT_KBN_RAISE)
    expect(@tern_action_raise.chip).to eq(100)
    expect(@tern_action_raise.kbn_str).to eq('raise')
  end
end


