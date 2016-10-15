require 'rails_helper'
require 'support/card_support'

RSpec.describe DlStartHandService, type: :service do
  describe 'do!' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = 
      @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_2
      @hand.users << @user_1
      @hand.users << @user_2
      @hand.betting_round = Hand::BR_PREFLOP
      @hand.save!
      
      df = DlNextBettingRoundForm.new({:hand_id => @hand.id})
      @ds = df.build_service
    end
    context 'next_betting_roundをしたとき' do
      before do
      end
      it 'プリフロップ⇒フロップに変わる' do
        @ds.do!
        @hand = Hand.find(@hand.id)
        expect(@hand.betting_round).to eq(Hand::BR_FLOP)
      end
      it '全員のactionがTernAction::ACT_KBN_NULLになっている' do
        @hand.hand_users.each do |hu|
          hu.last_action_kbn = TernAction::ACT_KBN_ALL_IN
          hu.save!
        end
        @hand.save!
        @ds.do!
        @hand = Hand.find(@hand.id)
        @hand.hand_users.each do |hu|
          expect(hu.last_action_kbn).to eq(TernAction::ACT_KBN_NULL)
        end
      end
    end
  end
end
