class BroadcastBettingRoundJob < ApplicationJob
  queue_as :default

  def perform(room_id, betting_round_str)
    p "################## in BroadcastBettingRoundJob.perform"
    # Do something later
    ActionCable.server.broadcast "poker_channel_#{room_id}", {type: "msg_update_betting_round", DOM_betting_round: betting_round_str}
  end

  private
end
