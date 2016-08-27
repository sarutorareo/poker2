require 'rails_helper'

RSpec.describe RoomUser, type: :model do
  before do
    @user = FactoryGirl.create(:user)
  end
  it "room_userをcreateするとbloadcastがenqueue" do
    time = Time.current
    travel_to(time) do
      assertion = {
        job: EnteredBroadcastJob,
#        args: @message,
#        at: (time).to_i
      }
      assert_enqueued_with(assertion) { RoomUser.create!(:user_id => @user.id, :room_id => 1) }
    end
  end
end
