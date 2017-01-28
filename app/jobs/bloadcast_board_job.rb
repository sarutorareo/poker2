class BloadcastBoardJob < ApplicationJob
  queue_as :default

  def perform(room_id, board_str)
    p "################## in BloadcastBoardJob.perform"
    # Message.create! content: "before BloadcastBoardJob [#{board_str}]", room_id: room_id, user_name: 'dealer'
    ActionCable.server.broadcast "poker_channel_#{room_id}", {type: "msg_update_board", DOM_board: board_str}
    # Message.create! content: "after BloadcastBoardJob [#{board_str}]", room_id: room_id, user_name: 'dealer'
  end

  private
end
