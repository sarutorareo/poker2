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
      it 'プリフロップ⇒フロップに変わる' do
        @ds.do!
        @hand = Hand.find(@hand.id)
        expect(@hand.betting_round).to eq(Hand::BR_FLOP)
      end
    end
    context '全員がCallのとき' do
      it '全員のactionがTernAction::ACT_KBN_NULLになっている' do
        @hand.hand_users.each do |hu|
          hu.last_action = TernActionCall.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL, 100)
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
    context 'CallとFoldが混ざっているとき' do
      it 'CallのactionがTernAction::ACT_KBN_NULLになっていて、Foldのactionはキープされている' do
        @hand.hand_users.each_with_index do |hu, i|
          hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_FOLD) if i == 0
          hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL, 100) if i != 0
          hu.save!
        end
        @hand.save!
        @ds.do!
        @hand = Hand.find(@hand.id)
        @hand.hand_users.each_with_index do |hu, i|
          expect(hu.last_action.kbn).to eq(TernAction::ACT_KBN_FOLD) if i == 0
          expect(hu.last_action.kbn).to eq(TernAction::ACT_KBN_NULL) if i != 0
        end
      end
    end
    context 'CallとAllInが混ざっているとき' do
      it 'CallのactionがTernAction::ACT_KBN_NULLになっていて、Foldのactionはキープされている' do
        @hand.hand_users.each_with_index do |hu, i|
          hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL_ALL_IN, 100) if i == 0
          hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL, 100) if i != 0
          hu.save!
        end
        @hand.save!
        @ds.do!
        @hand = Hand.find(@hand.id)
        @hand.hand_users.each_with_index do |hu, i|
          expect(hu.last_action.kbn).to eq(TernAction::ACT_KBN_CALL_ALL_IN) if i == 0
          expect(hu.last_action.chip).to eq(100) if i == 0
          expect(hu.last_action.kbn).to eq(TernAction::ACT_KBN_NULL) if i != 0
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
