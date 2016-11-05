class DealCardsJob < ApplicationJob
  queue_as :default

  def perform(room_id, user_id, card_list_str)
    p "################## in DealCardsJob.perform"
    # Do something later
    ActionCable.server.broadcast "hand_user_channel_#{room_id}_#{user_id}", {type: "deal_cards", DOM_cards: card_list_str}
  end

  private
end
