class RoomsController < ApplicationController
  def show
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
    @room = Room.find(params[:id])
    @room_users = RoomUser.where(:room_id => @room.id) 
    p "###### room_users =" 
    p @room_users.inspect

    @messages = Message.where(:room_id => @room.id)
  end
  def index
    @rooms = Room.all
    @users = User.all
  end
end
