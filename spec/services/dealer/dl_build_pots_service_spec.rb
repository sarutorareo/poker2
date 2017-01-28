require 'rails_helper'

RSpec.describe DlBuildPotsService, type: :service do
  before do
    @user_1 = FactoryGirl.create(:user)
    @user_2 = FactoryGirl.create(:user)
    @room = Room.find(1)
    @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_2
    @hand.users << @user_1
    @hand.users << @user_2
    @hand.save!

    df = DlBuildPotsForm.new({:hand_id => @hand.id})
    @ds = df.build_service
  end
  describe 'do!' do
    context 'user_1が100, user_2が100かけているとき' do
      before do
        @hand.hand_users.each do |hu|
          hu.hand_total_chip = 100
          hu.save!
        end
      end
      it '200のポットがひとつ作られる' do
        pots = @ds.do!
        expect(pots.size).to eq(1)
        pot = pots[0]
        expect(pot.chip).to eq(200)
        expect(pot.hand_users.size).to eq(2)
        expect(pot.hand_users.map{|p| p.user_id}.include?(@user_1.id)).to eq(true)
        expect(pot.hand_users.map{|p| p.user_id}.include?(@user_2.id)).to eq(true)
      end
    end
    context 'user_1が100, user_2が100かけているが、user_2はfoldしているとき' do
      before do
        @hand.hand_users.each do |hu|
          hu.hand_total_chip = 100
          hu.last_action = TernActionFold.new if hu.user_id == @user_2.id
          hu.save!
        end
      end
      it '200のポットがひとつ作られる' do
        pots = @ds.do!
        expect(pots.size).to eq(1)
        pot = pots[0]
        expect(pot.chip).to eq(200)
        expect(pot.hand_users.size).to eq(1)
        expect(pot.hand_users.map{|p| p.user_id}.include?(@user_1.id)).to eq(true)
        expect(pot.hand_users.map{|p| p.user_id}.include?(@user_2.id)).to eq(false)
      end
    end
    context 'user_1が200, user_2が100かけているとき' do
      before do
        hu = @hand.hand_users[0]
        hu.hand_total_chip = 200
        hu.save!
        hu = @hand.hand_users[1]
        hu.hand_total_chip = 100
        hu.save!
      end
      it '200のポットと100のポットが作られる' do
        pots = @ds.do!
        expect(pots.size).to eq(2)
        pot = pots[0]
        expect(pot.chip).to eq(200)
        expect(pot.hand_users.size).to eq(2)
        expect(pot.hand_users.map{|p| p.user_id}.include?(@user_1.id)).to eq(true)
        expect(pot.hand_users.map{|p| p.user_id}.include?(@user_2.id)).to eq(true)
        pot = pots[1]
        expect(pot.chip).to eq(100)
        expect(pot.hand_users.size).to eq(1)
        expect(pot.hand_users.map{|p| p.user_id}.include?(@user_1.id)).to eq(true)
        expect(pot.hand_users.map{|p| p.user_id}.include?(@user_2.id)).to eq(false)
      end
    end
    context 'user_1が200, user_2が100, user_3が101かけているがfold, user_4が200かけているとき' do
      before do
        @user_3 = FactoryGirl.create(:user)
        @user_4 = FactoryGirl.create(:user)
        @hand.users << @user_3
        @hand.users << @user_4
        hu = @hand.hand_users[0]
        hu.hand_total_chip = 200
        hu.save!
        hu = @hand.hand_users[1]
        hu.hand_total_chip = 100
        hu.save!
        hu = @hand.hand_users[2]
        hu.hand_total_chip = 101
        hu.last_action = TernActionFold.new
        hu.save!
        hu = @hand.hand_users[3]
        hu.hand_total_chip = 200
        hu.save!
      end
      it '100*4=400(全員), 1*3=3(user_1, 3, 4), 99*2=198のポット(user_1, 4)が作られる' do
        pots = @ds.do!
        expect(pots.size).to eq(3)
        pot = pots[0]
        expect(pot.chip).to eq(400)
        expect(pot.hand_users.size).to eq(3)
        user_ids = pot.hand_users.map{|p| p.user_id}
        expect(user_ids.include?(@user_1.id)).to eq(true)
        expect(user_ids.include?(@user_2.id)).to eq(true)
        expect(user_ids.include?(@user_3.id)).to eq(false)
        expect(user_ids.include?(@user_4.id)).to eq(true)
        pot = pots[1]
        expect(pot.chip).to eq(3)
        expect(pot.hand_users.size).to eq(2)
        user_ids = pot.hand_users.map{|p| p.user_id}
        expect(user_ids.include?(@user_1.id)).to eq(true)
        expect(user_ids.include?(@user_2.id)).to eq(false)
        expect(user_ids.include?(@user_3.id)).to eq(false)
        expect(user_ids.include?(@user_4.id)).to eq(true)
        pot = pots[2]
        expect(pot.chip).to eq(198)
        expect(pot.hand_users.size).to eq(2)
        user_ids = pot.hand_users.map{|p| p.user_id}
        expect(user_ids.include?(@user_1.id)).to eq(true)
        expect(user_ids.include?(@user_2.id)).to eq(false)
        expect(user_ids.include?(@user_3.id)).to eq(false)
        expect(user_ids.include?(@user_4.id)).to eq(true)
      end
    end
  end
  describe '_get_min_hand_total_chip' do
    context 'user_1は100, user_2は200のとき' do
      before do
        hu = @hand.hand_users[0]
        hu.hand_total_chip = 100
        hu.save!
        hu = @hand.hand_users[1]
        hu.hand_total_chip = 200
        hu.save!
      end
      context 'before_min_chipは0のとき' do
        before do
          @before_min_chip = 0
        end
        it '100が返る' do
          min_chip = @ds.send(:_get_min_hand_total_chip, @hand, @before_min_chip)
          expect(min_chip).to eq(100)
        end
      end
      context 'before_min_chipは100のとき' do
        before do
          @before_min_chip = 100
        end
        it '200が返る' do
          min_chip = @ds.send(:_get_min_hand_total_chip, @hand, @before_min_chip)
          expect(min_chip).to eq(200)
        end
      end
      context 'before_min_chipは200のとき' do
        before do
          @before_min_chip = 200
        end
        it 'nilが返る' do
          min_chip = @ds.send(:_get_min_hand_total_chip, @hand, @before_min_chip)
          expect(min_chip).to eq(nil)
        end
      end
    end
  end
end
