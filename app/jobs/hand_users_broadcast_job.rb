require 'color_log'

WAIT_TIME_HAND_USERS_BROAD_CAST_JOB = 0
class HandUsersBroadcastJob < ApplicationJob
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
    "to call:#{hand.call_chip}, to minimum raise:#{hand.min_raise_chip}"
  end
end
