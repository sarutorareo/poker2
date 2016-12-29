require 'rails_helper'

RSpec.describe DlJudgeUserHandWinnerService, type: :service do
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
      
    end
    context 'user_1:AA, user_2:KKなら' do
      before do
        @hand.hand_users.each do |hu|
          if hu.user_id == @user_1.id
            hu.user_hand << Card.new_from_str("SA")
            hu.user_hand << Card.new_from_str("CA")
          else
            hu.user_hand << Card.new_from_str("SK")
            hu.user_hand << Card.new_from_str("CK")
          end
          hu.save!
        end
        df = DlJudgeUserHandWinnerForm.new({:hand_id => @hand.id})
        @ds = df.build_service
      end
      it 'srv.winnerにuser_1のidが入る' do
        @ds.do!
        expect(@ds.winner_user_ids.count).to eq(1)
        expect(@ds.winner_user_ids[0]).to eq(@user_1.id)
      end
    end
    context 'user_1:52, user_2:35なら' do
      before do
        @hand.hand_users.each do |hu|
          if hu.user_id == @user_1.id
            hu.user_hand << Card.new_from_str("S5")
            hu.user_hand << Card.new_from_str("C2")
          else
            hu.user_hand << Card.new_from_str("S3")
            hu.user_hand << Card.new_from_str("C5")
          end
          hu.save!
        end
        df = DlJudgeUserHandWinnerForm.new({:hand_id => @hand.id})
        @ds = df.build_service
      end
      it 'srv.winnerにuser_2のidが入る' do
        @ds.do!
        expect(@ds.winner_user_ids.count).to eq(1)
        expect(@ds.winner_user_ids[0]).to eq(@user_2.id)
      end
    end
    context 'user_1:52, user_2:25なら' do
      before do
        @hand.hand_users.each do |hu|
          if hu.user_id == @user_1.id
            hu.user_hand << Card.new_from_str("S5")
            hu.user_hand << Card.new_from_str("C2")
          else
            hu.user_hand << Card.new_from_str("S2")
            hu.user_hand << Card.new_from_str("C5")
          end
          hu.save!
        end
        df = DlJudgeUserHandWinnerForm.new({:hand_id => @hand.id})
        @ds = df.build_service
      end
      it 'srv.winnerにuser_1, user_2のidが入る' do
        @ds.do!
        expect(@ds.winner_user_ids.count).to eq(2)
        expect(@ds.winner_user_ids[0]).to eq(@user_1.id)
        expect(@ds.winner_user_ids[1]).to eq(@user_2.id)
      end
    end
    context 'user_1:78, user_2:93なら' do
      before do
        @hand.hand_users.each do |hu|
          if hu.user_id == @user_1.id
            hu.user_hand << Card.new_from_str("C7")
            hu.user_hand << Card.new_from_str("H8")
          else
            hu.user_hand << Card.new_from_str("H9")
            hu.user_hand << Card.new_from_str("C3")
          end
          hu.save!
        end
        df = DlJudgeUserHandWinnerForm.new({:hand_id => @hand.id})
        @ds = df.build_service
      end
      it 'srv.winnerにuser_2のidが入る' do
        @ds.do!
        p @ds.winner_user_ids
        expect(@ds.winner_user_ids.count).to eq(1)
        expect(@ds.winner_user_ids[0]).to eq(@user_2.id)
      end
    end
    context 'user_1:93, user_2:78なら' do
      before do
        @hand.hand_users.each do |hu|
          if hu.user_id == @user_1.id
            hu.user_hand << Card.new_from_str("H9")
            hu.user_hand << Card.new_from_str("C3")
          else
            hu.user_hand << Card.new_from_str("C7")
            hu.user_hand << Card.new_from_str("H8")
          end
          hu.save!
        end
        df = DlJudgeUserHandWinnerForm.new({:hand_id => @hand.id})
        @ds = df.build_service
      end
      it 'srv.winnerにuser_2のidが入る' do
        @ds.do!
        p @ds.winner_user_ids
        expect(@ds.winner_user_ids.count).to eq(1)
        expect(@ds.winner_user_ids[0]).to eq(@user_1.id)
      end
    end
  end
end
