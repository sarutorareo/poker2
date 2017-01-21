require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @hand_user_mock = double('hand_user_mock')
    allow(@hand_user_mock).to receive(:round_total_chip).and_return(100)

    @hand_mock = double('hand_mock')
    allow(@hand_mock).to receive(:call_chip).and_return(100)
    allow(@hand_mock).to receive(:min_raise_chip).and_return(200)
    allow(@hand_mock).to receive(:get_hand_user_from_user_id).and_return(@hand_user_mock)
  end
  context 'デフォルトの場合' do
    before do
      @user = FactoryGirl.create(:user)
    end
    it '名前はtest_name' do
      expect(@user.name).to eq("test_name")
    end
    it 'user_type は 0(人間)' do
      expect(@user.user_type).to eq(0)
    end
    it 'tern_actionを返すことはできない' do
      expect(@user.tern_action(@hand_mock).kind_of?(TernAction)).to eq(false)
    end
    it 'is_cpu?はfalse' do
      expect(@user.is_cpu?).to eq(false)
    end
  end
  context 'CPUの場合' do
    it 'user_type は 1(CPU)' do
      @user = FactoryGirl.create(:user, :user_type=>1)
      @user = User.find(@user.id)
      expect(@user.user_type).to eq(1)
    end
    it 'tern_actionを返すことができる(Factoryで生成されたインスタンスのafter_initializeは、属性値を代入する前に呼ばれているため、User.findで読み直している' do
      @user = FactoryGirl.create(:user, :user_type=>1)
      @user = User.find(@user.id)
      expect(@user.tern_action(@hand_mock).kind_of?(TernAction)).to eq(true)
    end
    it 'newの場合は一発でuser_type=1になるため、読み直す必要なくafter_initializeにより、CpuUserがextendされる' do
      @user = User.new(:user_type=>1)
      expect(@user.tern_action(@hand_mock).kind_of?(TernAction)).to eq(true)
    end
    it 'is_cpu?はfalse' do
      @user = User.new(:user_type=>1)
      expect(@user.is_cpu?).to eq(true)
    end
  end
end
