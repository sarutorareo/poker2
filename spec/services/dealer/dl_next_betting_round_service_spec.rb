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
          hu.last_action = TernActionCall.new(100)
          hu.save!
        end
        @hand.save!
        @ds.do!
        @hand = Hand.find(@hand.id)
        @hand.hand_users.each do |hu|
          expect(hu.last_action.kind_of?(TernActionNull)).to eq(true)
        end
      end
    end
    context 'flopになったら' do
      before do
        @hand.betting_round = Hand::BR_PREFLOP
        @hand.save!
      end
      it 'boardに３枚のカードを開く' do
        deck_num = @hand.deck.count
        @ds.do!
        @hand = Hand.find(@hand.id)
        expect(@hand.betting_round).to eq(Hand::BR_FLOP)
        expect(@hand.board.count).to eq(3)
        expect(@hand.deck.count).to eq(deck_num - 3)
      end
    end
    context 'flop, turnになったら' do
      before do
        @hand.betting_round = Hand::BR_PREFLOP
        @hand.save!
      end
      it 'boardに３枚, 1枚のカードを開く' do
        deck_num = @hand.deck.count
        @ds.do!
        @hand = Hand.find(@hand.id)
        expect(@hand.betting_round).to eq(Hand::BR_FLOP)
        expect(@hand.board.count).to eq(3)
        expect(@hand.deck.count).to eq(deck_num - 3)

        @ds.do!
        @hand = Hand.find(@hand.id)
        expect(@hand.betting_round).to eq(Hand::BR_TURN)
        expect(@hand.board.count).to eq(4)
        expect(@hand.deck.count).to eq(deck_num - 4)
      end
    end
  end
end
