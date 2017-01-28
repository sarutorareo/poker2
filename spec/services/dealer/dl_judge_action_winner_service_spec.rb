require 'rails_helper'

RSpec.describe DlJudgeActionWinnerService, type: :service do
  describe 'do!' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      @hand.users << @user_1
      @hand.users << @user_2
      @hand.save!
      
      df = DlJudgeActionWinnerForm.new({:hand_id => @hand.id})
      @ds = df.build_service
    end
    context 'user_1:CALLを除いて全員foldなら' do
      before do
        @hand.hand_users.each do |hu|
          if hu.user_id == @user_1.id
            hu.last_action = TernActionCall.new(100)
          else
            hu.last_action = TernActionFold.new
          end
          hu.save!
        end
      end
      it 'srv.winnerにuser_1のidが入る' do
        @ds.do!
        expect(@ds.winner_user_id).to eq(@user_1.id)
      end
    end
    context 'user_2:CALLを除いて全員foldなら' do
      before do
        @hand.hand_users.each do |hu|
          if hu.user_id == @user_2.id
            hu.last_action = TernActionCall.new(100)
          else
            hu.last_action = TernActionFold.new
          end
          hu.save!
        end
      end
      it 'srv.winnerにuser_2のidが入る' do
        @ds.do!
        expect(@ds.winner_user_id).to eq(@user_2.id)
      end
    end
    context '全員foldなら' do
      before do
        @hand.hand_users.each do |hu|
          hu.last_action = TernActionFold.new
          hu.save!
        end
      end
      it 'srv.winnerにnilが入る' do
        @ds.do!
        expect(@ds.winner_user_id).to eq(nil)
      end
    end
    context '一人でもアクションしていない人がいたら' do
      before do
        @hand.hand_users.each do |hu|
          if hu.user_id == @user_1.id
            hu.last_action = TernActionNull.new
          else
            hu.last_action = TernActionCall.new(100)
          end
          hu.save!
        end
      end
      it 'srv.winnerにnilが入る' do
        @ds.do!
        expect(@ds.winner_user_id).to eq(nil)
      end
    end
    context '全員Callなら' do
      before do
        @hand.hand_users.each do |hu|
          hu.last_action = TernActionCall.new(100)
          hu.save!
        end
      end
      it 'srv.winnerにnilが入る' do
        @ds.do!
        expect(@ds.winner_user_id).to eq(nil)
      end
    end
  end
end
