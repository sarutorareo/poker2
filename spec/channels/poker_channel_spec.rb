require 'rails_helper'
require Rails.root.join('test/stubs/test_connection.rb')

RSpec.describe PokerChannel, type: :channel do
  before do
    conn = TestConnection.new
    identifier = {'channel' => 'PokerChannel'}
    @ch = PokerChannel.new(conn, identifier.to_json, identifier)
  end
  describe 'initialize connection' do
    it 'TestConnectionをnewできる' do
      conn = TestConnection.new
    end
  end
  describe 'initialize channel' do
    before do
    end
    it "チャンネルをnewできる" do
      conn = TestConnection.new
      identifier = {'channel' => 'PokerChannel'}
      ch = PokerChannel.new(conn, identifier.to_json, identifier)
    end
  end
  describe 'is_round_all' do
    before do
    end
    context 'handが存在しない場合' do
      it 'falseが返る' do
        expect(@ch.is_rounded_all?(nil)).to eq(false)
      end
    end
    context 'handが存在する場合' do
      it 'handが判定した値が返る' do
        hand_mock = double('hand_mock')
        allow(hand_mock).to receive(:rotated_all?).and_return(true)
        allow(@ch).to receive(:get_hand).and_return(hand_mock)

        expect(@ch.is_rounded_all?(hand_mock)).to eq(true)
      end
    end
  end
  describe 'get_next_tern_user' do
    before do
      @user = User.new()
      @hand_mock = double('hand_mock')
    end
    context 'handが存在する場合' do
      before do
        allow(@ch).to receive(:get_hand).and_return(@hand_mock)
      end

      context 'ユーザーがいる場合' do
        before do
          allow(@hand_mock).to receive(:tern_user).and_return(@user)
        end
        it 'ユーザーを返す' do
          expect(@ch.get_next_tern_user(0).kind_of?(User)).to eq(true)
          expect(@ch.get_next_tern_user(0)).to eq(@user)
        end
      end
      context 'ユーザーがいない場合' do
        before do
          allow(@hand_mock).to receive(:tern_user).and_return(nil)
        end
        it 'nilを返す' do
          expect(@ch.get_next_tern_user(0)).to eq(nil)
        end
      end
    end
    context 'handが存在しない場合' do
      before do
      end
      it 'nilを返す' do
        expect(@ch.get_next_tern_user(0)).to eq(nil)
      end
    end
  end
  describe 'prompt_tern_action_to_next_user' do
    before do
      @user = User.new(:id=>0)
      allow(@ch).to receive(:get_next_tern_user).and_return(@user)
    end
    it "promptするとuserにアクションを促すためのjobが登録される" do
      expect(@user.id.blank?).to eq(false)
      data = {}
      data['hand_id'] = 0
      data['user_id'] = @user.id

      time = Time.current
      travel_to(time) do
        room_id = 9
        assertion = {
          job: PromptTernActionJob,
          args: [room_id, @user]
#          at: (time).to_i
        }
        assert_enqueued_with(assertion) { @ch.prompt_tern_action_to_next_user(room_id, data) }
      end
    end
  end
end

