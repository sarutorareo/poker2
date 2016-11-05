# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class HandUserChannel < ApplicationCable::Channel
  def subscribed
    p "############### subscribed hand_user_channel"
    room = Room.find(params[:room_id])
    user = User.find(params[:user_id])
    stream_from "hand_user_channel_#{params[:room_id]}_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    p "############### unsubscribed hand_user_channel"
  end

private
end
