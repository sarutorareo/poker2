class SendBettingRoundJob < ApplicationJob
  queue_as :default

  def perform(room_id, betting_round_str)
    p "################## in SendBettingRoundJob.perform"
    # Do something later
    ActionCable.server.broadcast "room_channel_#{room_id}", {type: "msg_update_betting_round", DOM_betting_round: betting_round_str}
  end

  private
end
