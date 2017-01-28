require 'rails_helper'

RSpec.describe DlApplyPotsService, type: :service do
  before do
    @user_1 = FactoryGirl.create(:user)
    @user_2 = FactoryGirl.create(:user)
    @user_3 = FactoryGirl.create(:user)
    @user_2.chip = 100
    @user_2.save!
    @room = Room.find(1)
    @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_2
    @hand.users << @user_1
    @hand.users << @user_2
    @hand.users << @user_3
    @hand.save!
  end
  describe 'do!' do
    context '(１００、user_1)のpotが１つのとき' do
      before do
        pots = []
        pots << Pot.new_from_values(100, @hand.hand_users.where(:user_id => @user_1.id))

        df = DlApplyPotsForm.new({:hand_id => @hand.id,
                                 :pots => pots})
        @ds = df.build_service
      end
      it 'user_1のchipが100増える' do
        user_1 = User.find(@user_1.id)
        expect(user_1.chip).to eq(0)
        @ds.do!
        user_1 = User.find(@user_1.id)
        expect(user_1.chip).to eq(100)
      end
    end
    context '(300、user_1, user_2)のpotが１つのとき' do
      before do
        pots = []
        pots << Pot.new_from_values(300, @hand.hand_users.select{|hu| hu.user_id == @user_1.id || hu.user_id == @user_2.id})

        df = DlApplyPotsForm.new({:hand_id => @hand.id,
                                  :pots => pots})
        @ds = df.build_service
      end
      it 'user_1, user_2のchipが150増える' do
        user_1 = User.find(@user_1.id)
        user_2 = User.find(@user_2.id)
        expect(user_1.chip).to eq(0)
        expect(user_2.chip).to eq(100)
        @ds.do!
        user_1 = User.find(@user_1.id)
        user_2 = User.find(@user_2.id)
        expect(user_1.chip).to eq(150)
        expect(user_2.chip).to eq(250)
      end
    end
    context '(300、user_1, user_2), (200、user_2)のpotが2つのとき' do
      before do
        pots = []
        pots << Pot.new_from_values(300, @hand.hand_users.select{|hu| hu.user_id == @user_1.id || hu.user_id == @user_2.id})
        pots << Pot.new_from_values(200, @hand.hand_users.where(:user_id=>@user_2.id))

        df = DlApplyPotsForm.new({:hand_id => @hand.id,
                                  :pots => pots})
        @ds = df.build_service
      end
      it 'user_1のchipが150増える, user_2のチップが150+200=350増える' do
        user_1 = User.find(@user_1.id)
        user_2 = User.find(@user_2.id)
        expect(user_1.chip).to eq(0)
        expect(user_2.chip).to eq(100)
        @ds.do!
        user_1 = User.find(@user_1.id)
        user_2 = User.find(@user_2.id)
        expect(user_1.chip).to eq(150)
        expect(user_2.chip).to eq(450)
      end
    end
    context '端数がでたとき' do
      context '(301、user_1, user_2)のpotが1つのとき' do
        before do
          pots = []
          pots << Pot.new_from_values(301, @hand.hand_users.select{|hu| hu.user_id == @user_1.id || hu.user_id == @user_2.id})
          df = DlApplyPotsForm.new({:hand_id => @hand.id,
                                    :pots => pots})
          @ds = df.build_service
        end
        it 'ポジションの悪いuser_2が端数をもらう　user_1のchipが150増える, user_2のchipが151増える' do
          user_1 = User.find(@user_1.id)
          user_2 = User.find(@user_2.id)
          expect(user_1.chip).to eq(0)
          expect(user_2.chip).to eq(100)
          @ds.do!
          user_1 = User.find(@user_1.id)
          user_2 = User.find(@user_2.id)
          expect(user_1.chip).to eq(150)
          expect(user_2.chip).to eq(251)
        end
      end
      context '(302、 user_1, user_2, user_3)のpotが1つのとき' do
        before do
          pots = []
          pots << Pot.new_from_values(302, @hand.hand_users)
          df = DlApplyPotsForm.new({:hand_id => @hand.id,
                                    :pots => pots})
          @ds = df.build_service
        end
        it 'ポジションの悪い2が端数をもらう　user_1, user_3のchipが100増える, user_2のchipが102増える' do
          user_1 = User.find(@user_1.id)
          user_2 = User.find(@user_2.id)
          user_3 = User.find(@user_3.id)
          expect(user_1.chip).to eq(0)
          expect(user_2.chip).to eq(100)
          expect(user_3.chip).to eq(0)
          @ds.do!
          user_1 = User.find(@user_1.id)
          user_2 = User.find(@user_2.id)
          user_3 = User.find(@user_3.id)
          expect(user_1.chip).to eq(100)
          expect(user_2.chip).to eq(202)
          expect(user_3.chip).to eq(100)
        end
      end
    end
  end
end
