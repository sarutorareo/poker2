class RoomsController < ApplicationController
  def show
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
    @room = Room.find(params[:id])

    p "####### 入室"
    #roomにユーザーを追加する
    #すでに@user_idが存在する場合はvalidationによりActiveRecord::RecordInvalidが発生する
    begin
      @room.users << @user unless @user.blank?
      @room.save
    rescue ActiveRecord::RecordInvalid => ex
      #何もしない
    end

    EnteredBroadcastJob.set(wait: WAIT_TIME_ENTERED_BROAD_CAST_JOB.second).perform_later RoomUser.where(:room_id => @room.id, :user_id => @user.id).first

    @messages = Message.where(:room_id => @room.id)
  end

  def index
    @rooms = Room.all
    @users = User.all
  end
end
