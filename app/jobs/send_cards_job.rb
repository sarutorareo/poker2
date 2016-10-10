class SendCardsJob < ApplicationJob
  queue_as :default

  def perform(room_id, user_id, card_list_str)
    # Do something later
    ActionCable.server.broadcast "room_channel_#{message.room_id}", {type: "msg_card", DOM_cards: card_list_str}
  end

  private
end
