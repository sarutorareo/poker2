class BloadcastRoundTotalChipJob < ApplicationJob
  queue_as :default

  def perform(room_id, user_id, round_total_chip)
    # Do something later
    ActionCable.server.broadcast "hand_user_channel_#{room_id}_#{user_id}", {type: "send_round_total_chip", DOM_round_total_chip: round_total_chip}
  end

  private
end
