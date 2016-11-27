# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class PokerChannel < ApplicationCable::Channel

  def subscribed
    return if params[:room_id].blank?

    p "############### subscribed poker"
    stream_from "poker_channel_#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    p "############### unsubscribed"
  end

  def start_hand(data)
    p "############### start_hand"
    # 新たなハンドを作成する
    hand = Game.start_hand(params[:room_id])
  end

  def tern_action(data)
    p "############### tern_action"
    p data.inspect
    Game.tern_action(data)
  end

private
  
end
