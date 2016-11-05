require 'rails_helper'
require Rails.root.join('test/stubs/test_connection.rb')

RSpec.describe RoomChannel, type: :channel do
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
      identifier = {'channel' => 'RoomChannel'}
      ch = RoomChannel.new(conn, identifier.to_json, identifier)
    end
  end
end

