WAIT_TIME_ENTERED_BROAD_CAST_JOB = 0
class EnteredBroadcastJob < ApplicationJob
  queue_as :default

  def perform(room_id)
    ActionCable.server.broadcast "room_channel_#{room_id}", {type: "entered_message", user_list: render_user_list(room_id)}
  end

  def render_user_list(room_id)
    return ApplicationController.renderer.render(partial: 'room_user/index', locals: { room_users: RoomUser.where(:room_id => room_id) } )
  end

  private
end
