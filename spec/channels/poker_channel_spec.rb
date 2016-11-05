require 'rails_helper'
require Rails.root.join('test/stubs/test_connection.rb')

RSpec.describe PokerChannel, type: :channel do
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
      conn = TestConnection.new
      identifier = {'channel' => 'PokerChannel'}
      @ch = PokerChannel.new(conn, identifier.to_json, identifier)
    end
    context 'handが存在しない場合' do
      it 'falseが返る' do
        expect(@ch.is_rounded_all?(9999)).to eq(false)
      end
    end
    context 'handが存在する場合' do
      it 'handが判定した値が返る' do
        hand_mock = double('hand_mock')
        allow(hand_mock).to receive(:rotated_all?).and_return(true)

        allow(@ch).to receive(:get_hand).and_return(hand_mock)

        expect(@ch.is_rounded_all?(0)).to eq(true)
      end
    end
  end
end

