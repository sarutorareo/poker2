WAIT_TIME_START_HAND_BROAD_CAST_JOB = 0
class StartHandBroadcastJob < ApplicationJob
  queue_as :default

  def perform(room_id, hand_id)
    p "###### in StartHandBroadcastJob perform room_id=#{room_id} hand_id=#{hand_id}"
    ActionCable.server.broadcast "room_channel_#{room_id}", {type: "msg_start_hand", DOM_hand_user_list: render_user_list(hand_id)}
  end

  private
  def render_user_list(hand_id)
    return ApplicationController.renderer.render(partial: 'hand_user/index', locals: { hand: Hand.find(hand_id) } )
  end
end
