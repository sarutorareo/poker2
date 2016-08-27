# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    p "############### subscribed"
    @room = Room.find(params[:room_id])
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
    #roomにユーザーを追加する
    #すでに@user_idが存在する場合はvalidationによりActiveRecord::RecordInvalidが発生する
    begin
      @room.users << @user unless @user.blank?
      @room.save
    rescue ActiveRecord::RecordInvalid => ex
      #何もしない
    end
    stream_from "room_channel_#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    p "############### unsubscribed"
    @room = Room.find(params[:room_id])
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
    @room.users.destroy(@user) unless params[:user_id].blank?
    @room.save
  end

  def speak(data)
    # ActionCable.server.broadcast 'room_channel', message: data['message']
    Message.create! content: data['message'], room_id: data['room_id']
  end
end
