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
end

