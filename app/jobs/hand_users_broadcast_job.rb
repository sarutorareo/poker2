WAIT_TIME_HAND_USERS_BROAD_CAST_JOB = 0
class HandUsersBroadcastJob < ApplicationJob
  queue_as :default

  def perform(room_id, hand_id)
    # ColorLog.clog "###### in HandUsersBroadcastJob perform room_id=#{room_id} hand_id=#{hand_id}"
    Message.create! content: "before HandUsers [#{hand_id}]", room_id: room_id, user_name: 'dealer'
    Message.create! content: " HandUsers is [#{render_user_list(hand_id)}]", room_id: room_id, user_name: 'dealer'
    ActionCable.server.broadcast "poker_channel_#{room_id}", {type: "msg_hand_users", DOM_hand_user_list: render_user_list(hand_id)}
    Message.create! content: "before HandUsers [#{hand_id}]", room_id: room_id, user_name: 'dealer'
  end

  private
  def render_user_list(hand_id)
    return ApplicationController.renderer.render(partial: 'hand_user/index', locals: { hand: Hand.find(hand_id) } )
  end
end
