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
      @hand.save!
      
      df = DlStartHandForm.new({:hand_id => @hand.id})
      @ds = df.build_service
    end
    context 'start_handをしたとき' do
      before do
      end
      it '@handのデッキがシャッフルされている' do
        deck = Deck.new
        hand_deck = @hand.deck
        expect(CardSupport.comp_card_list_order(deck, hand_deck)).to eq(true)

        @ds.do!
        hand_deck = Hand.find(@hand.id).deck
        expect(CardSupport.comp_card_list_order(deck, hand_deck)).to eq(false)
      end
      it '各ユーザーに２枚ずつカードが配られている' do
        @ds.do!
        hand = Hand.find(@hand.id)
        hand.hand_users.each do |hu|
          expect(hu.user_hand.count).to eq(2)
        end
      end
    end
  end
end
