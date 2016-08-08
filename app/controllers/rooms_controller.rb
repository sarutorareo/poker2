class RoomsController < ApplicationController
  def show
    @room = Room.find(params[:id])
    @messages = Message.where(:room_id => @room.id)
  end
  def index
    @rooms = Room.all
  end
end
