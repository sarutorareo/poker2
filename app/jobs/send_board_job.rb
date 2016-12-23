class SendBoardJob < ApplicationJob
  queue_as :default

  def perform(room_id, board_str)
    p "################## in SendBoardJob.perform"
    # Message.create! content: "before SendBoardJob [#{board_str}]", room_id: room_id, user_name: 'dealer'
    ActionCable.server.broadcast "poker_channel_#{room_id}", {type: "msg_update_board", DOM_board: board_str}
    # Message.create! content: "after SendBoardJob [#{board_str}]", room_id: room_id, user_name: 'dealer'
  end

  private
end
