class RoomsController < ApplicationController
  def show
    @room = Room.find(params[:id])
    @user = User.find(params[:user_id])

    p "####### 入室2"
    @messages = Message.where(:room_id => @room.id)
  end

  def index
    @rooms = Room.all
    @users = User.all
  end

  def start_hand
    p params

    @room = Room.find(params[:id])
    @user = User.find(params[:user_id])
    @messages = Message.where(:room_id => @room.id)
    render action: :show
  end
end
