require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'enqueue' do
    it "メッセージをcreateするとbloadcastがenqueue" do
      time = Time.current
      travel_to(time) do
        assertion = {
          job: BloadcastMessageJob,
  #        args: @message,
  #        at: (time).to_i
        }
        assert_enqueued_with(assertion) { Message.create!(content: "test", room_id: 1, user_name:'test_user') }
      end
    end
  end
end
