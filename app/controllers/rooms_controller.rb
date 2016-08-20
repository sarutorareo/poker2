class RoomsController < ApplicationController
  def show
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
    @room = Room.find(params[:id])
    @messages = Message.where(:room_id => @room.id)
  end
  def index
    @rooms = Room.all
    @users = User.all
  end
end
