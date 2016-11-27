class RoomsController < ApplicationController
  def show
    p "####### 入室2"
    _prepare_render_show(params)
  end

  def index
    @rooms = Room.all
    @users = User.where(:user_type=>User::UT_HUMAN)
  end

  private
  def _prepare_render_show(_params)
    @room = Room.find(_params[:id])
    @user = User.find(_params[:user_id])
    @messages = Message.where(:room_id => @room.id)
  end
end
