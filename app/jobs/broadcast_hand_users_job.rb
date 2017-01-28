require 'color_log'

WAIT_TIME_HAND_USERS_BROAD_CAST_JOB = 0
class BroadcastHandUsersJob < ApplicationJob
  queue_as :default

  def perform(room_id, hand_id)
    hand = Hand.find(hand_id)
    ActionCable.server.broadcast "poker_channel_#{room_id}", {type: "msg_hand_users", DOM_hand_user_list: _render_user_list(hand), DOM_round_rules: _render_round_rules(hand)}
  end

  private
  def _render_user_list(hand)
    ApplicationController.renderer.render(partial: 'hand_user/index', locals: { hand: hand } )
  end

  def _render_round_rules(hand)
    ApplicationController.renderer.render(partial: 'hand/round_rules', locals: { hand: hand } )
  end
end
