class EnteredBroadcastJob < ApplicationJob
  queue_as :default

  def perform(room_user)
    ActionCable.server.broadcast "room_channel_#{room_user.room_id}", {type: "entered_message", user_list: render_message(room_user)}
  end

  private
  def render_message(room_user)
    "<p>entered user_id=#{User.find(room_user.user_id).name} (#{room_user.user_id})</p>"
  end
end
