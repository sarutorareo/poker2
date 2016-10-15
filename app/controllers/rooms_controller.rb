class RoomsController < ApplicationController
  def show
    p "####### 入室2"
    binding.pry
    _prepare_render_show(params)
  end

  def index
    @rooms = Room.all
    @users = User.all
  end

  private
  def _prepare_render_show(_params)
    @room = Room.find(_params[:id])
    @user = User.find(_params[:user_id])
    @messages = Message.where(:room_id => @room.id)
  end
end
