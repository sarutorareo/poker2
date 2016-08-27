WAIT_TIME_ENTERED_BROAD_CAST_JOB = 2
class ExitedBroadcastJob < ApplicationJob
  queue_as :default

  def perform(room_user)
    ActionCable.server.broadcast "room_channel_#{room_user.room_id}", {type: "exited_message", user_list: EnteredBroadCastJob::render_user_list(room_user.room_id)}
  end
end
