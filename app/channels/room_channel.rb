# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    p "############### 入室"
    p "############### in subscribed"
    p params
    @room = Room.find(params[:room_id])
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
    @room.users << @user unless @user.blank?
    @room.save
    stream_from "room_channel_#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    p "############### 退室"
  end

  def speak(data)
    # ActionCable.server.broadcast 'room_channel', message: data['message']
    Message.create! content: data['message'], room_id: data['room_id']
  end
end
