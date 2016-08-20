require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryGirl.create(:user)
  end
  it '名前はtest_name' do
    expect(@user.name).to eq("test_name")

  end

end
