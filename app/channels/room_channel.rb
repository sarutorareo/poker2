# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    p "############### subscribed"
    room = Room.find(params[:room_id])
    user = User.find(params[:user_id]) unless params[:user_id].blank?
    #roomにユーザーを追加する
    #すでに@user_idが存在する場合はvalidationによりActiveRecord::RecordInvalidが発生する
    begin
      room.users << user unless user.blank?
      room.save
    rescue ActiveRecord::RecordInvalid => ex
      #何もしない
    end
    stream_from "room_channel_#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    p "############### unsubscribed"
    room = Room.find(params[:room_id])
    user = User.find(params[:user_id]) unless params[:user_id].blank?
    room.users.destroy(user) unless params[:user_id].blank?
    room.save
  end

  def speak(data)
    user_name = User.find(data['user_id']).name unless data['user_id'].blank?
    Message.create! content: data['message_content'], room_id: data['room_id'], user_name: user_name
  end

  def pull_user_list(data)
    p "############### pull_user_list"
    RoomUsersBroadcastJob.set(wait: WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB.second).perform_later data['room_id']
  end

  def start_hand(data)
    p "############### start_hand"
    button_user = User.find(data['user_id']) unless data['user_id'].blank?
    room = Room.find(params[:room_id])
    hand = Hand.create! room_id: data['room_id'], button_user: button_user, tern_user: button_user
    hand.start_hand!(room.get_room_user_ids)
    hand.save!
  end

  def user_action(data)
    p "############### user_action"
    p data.inspect

    df = DlTernActionForm.new(data)
    srv = df.build_service
    srv.user_action()
  end
end
