class SendBoardJob < ApplicationJob
  queue_as :default

  def perform(room_id, board_str)
    p "################## in SendBoardJob.perform"
    ActionCable.server.broadcast "poker_channel_#{room_id}", {type: "msg_update_board", DOM_board: board_str}
  end

  private
end
