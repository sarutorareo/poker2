require 'rails_helper'

RSpec.describe DlTernActionService, type: :service do
  describe 'do! (actionしたユーザーのlast_action)' do
    before do
      @user_1 = FactoryGirl.create(:user, :chip=>1000)
      @user_2 = FactoryGirl.create(:user, :chip=>1000)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      @hand.users << @user_1
      @hand.users << @user_2
      @hand.save!

      @data = {}
      @data[:hand_id] = 0
      @data[:user_id] = 0
      @data[:tern_action] = TernActionNull
    end
    context 'tern_userの場合' do
      context 'user_1がfoldした場合' do
        before do
          @data[:hand_id] = @hand.id
          @data[:user_id] = @user_1.id
          @data[:tern_action] = TernActionFold.new
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'hand_userのactionが更新される' do
          expect(@hand.tern_user.id).to eq(@user_1.id)

          @ds.do!()
          @hand = Hand.find(@hand.id)
          #user_1のlast_actionが更新されている
          hand_user = @hand.hand_users.where(:user_id => @user_1.id).first
          expect(hand_user.last_action.kind_of?(TernActionFold)).to eq(true)
          #tern_userはuser_2になる
          expect(@hand.tern_user.id).to eq(@user_2.id)
        end
      end
      context 'user_2がcallした場合' do
        before do
          @hand.tern_user = @user_2
          @hand.save!

          @data[:hand_id] = @hand.id
          @data[:user_id] = @user_2.id
          @data[:tern_action] = TernActionCall.new(100)
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'hand_userのlast_action, round_total_chip, hand_total_chipが更新される' do
          expect(@hand.tern_user.id).to eq(@user_2.id)
          hand_user = @hand.hand_users.where(:user_id => @user_2.id).first
          expect(hand_user.hand_total_chip).to eq(0)
          expect(User.find(@user_2.id).chip).to eq(1000)

          @ds.do!

          @hand = Hand.find(@hand.id)
          #user_2のlast_actionが更新されている
          hand_user = @hand.hand_users.where(:user_id => @user_2.id).first
          expect(hand_user.last_action.kind_of?(TernActionCall)).to eq(true)
          expect(hand_user.last_action.chip).to eq(100)
          expect(hand_user.round_total_chip).to eq(100)
          expect(hand_user.hand_total_chip).to eq(100)
          expect(User.find(@user_2.id).chip).to eq(900)
          #tern_userはuser_1になる
          expect(@hand.tern_user.id).to eq(@user_1.id)
        end
      end
      context 'user_1が元々100かけている時に、さらに100を上乗せして200にraiseした場合' do
        before do
          @hand_user = @hand.hand_users.where(:user_id => @user_1.id).first
          @hand_user.round_total_chip = 100
          @hand_user.hand_total_chip = 100
          @hand_user.save!

          @data[:hand_id] = @hand.id
          @data[:user_id] = @user_1.id
          @data[:tern_action] = TernActionRaise.new(100)
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'ユーザーのchipは100減って、hand_total_chipが200になる, handのcall_chipは200になる' do
          @ds.do!
          hand = Hand.find(@hand.id)
          #user_2のlast_actionが更新されている
          hand_user = hand.hand_users.where(:user_id => @user_1.id).first
          expect(hand_user.last_action.kind_of?(TernActionRaise)).to eq(true)
          expect(hand_user.last_action.chip).to eq(100)
          expect(hand_user.round_total_chip).to eq(200)
          expect(hand_user.hand_total_chip).to eq(200)
          expect(User.find(@user_1.id).chip).to eq(900)
        end
      end
      context 'user_1が元々100かけている時に、さらに100を上乗せして200をcallした場合' do
        before do
          @hand_user = @hand.hand_users.where(:user_id => @user_1.id).first
          @hand_user.round_total_chip = 100
          @hand_user.hand_total_chip = 100
          @hand_user.save!

          @data[:hand_id] = @hand.id
          @data[:user_id] = @user_1.id
          @data[:tern_action] = TernActionCall.new(100)
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'ユーザーのchipは100減って、hand_total_chipが200になる, handのcall_chipは200になる' do
          @ds.do!
          hand = Hand.find(@hand.id)
          #user_2のlast_actionが更新されている
          hand_user = hand.hand_users.where(:user_id => @user_1.id).first
          expect(hand_user.last_action.kind_of?(TernActionCall)).to eq(true)
          expect(hand_user.last_action.chip).to eq(100)
          expect(hand_user.round_total_chip).to eq(200)
          expect(hand_user.hand_total_chip).to eq(200)
          expect(User.find(@user_1.id).chip).to eq(900)
        end
      end
      context 'user_1がチップ量ちょうどでRaiseした場合' do
        before do
          @data[:hand_id] = @hand.id
          @data[:user_id] = @user_1.id
          @data[:tern_action] = TernActionRaise.new(1000)
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'RaiseAllInしたことになる' do
          @ds.do!
          @hand = Hand.find(@hand.id)
          #user_1のlast_actionが更新されている
          hand_user = @hand.hand_users.where(:user_id => @user_1.id).first
          expect(hand_user.last_action.kind_of?(TernActionRaiseAllIn)).to eq(true)
          expect(hand_user.hand_total_chip).to eq(1000)
          expect(User.find(@user_1.id).chip).to eq(0)
        end
      end
      context 'user_1がチップ量ちょうどでcallした場合' do
        before do
          @user_1.chip = 100
          @user_1.save!
          @data[:hand_id] = @hand.id
          @data[:user_id] = @user_1.id
          @data[:tern_action] = TernActionCall.new(100)
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'CallAllInしたことになる' do
          @ds.do!
          @hand = Hand.find(@hand.id)
          #user_1のlast_actionが更新されている
          hand_user = @hand.hand_users.where(:user_id => @user_1.id).first
          expect(hand_user.last_action.kind_of?(TernActionCallAllIn)).to eq(true)
          expect(hand_user.hand_total_chip).to eq(100)
          expect(User.find(@user_1.id).chip).to eq(0)
        end
      end
    end
    context 'tern_userではない場合' do
      context 'user_2がcallした場合' do
        before do
          @data[:hand_id] = @hand.id
          @data[:user_id] = @user_2.id
          @data[:tern_action] = TernActionCall.new(100)
          df = DlTernActionForm.new(@data)
          @ds = df.build_service
        end
        it 'hand_userのactionが更新されない' do
          expect(@hand.tern_user.id).to eq(@user_1.id)

          @ds.do!

          @hand = Hand.find(@hand.id)
          #user_2のlast_actionが更新されていない
          hand_user = @hand.hand_users.where(:user_id => @user_2.id).first
          expect(hand_user.last_action.kind_of?(TernActionNull)).to eq(true)
          #tern_userはuser_1のまま
          expect(@hand.tern_user.id).to eq(@user_1.id)
        end
      end
    end
  end
  describe 'do! (現在のhandにおけるcall額とmin_raise額)' do
    before do
      @user_1 = FactoryGirl.create(:user, :chip=>1000)
      @user_2 = FactoryGirl.create(:user, :chip=>1000)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      @hand.users << @user_1
      @hand.users << @user_2
      @hand.save!

      @data = {}
      @data[:hand_id] = 0
      @data[:user_id] = 0
      @data[:tern_action] = TernActionNull
    end
    context 'user_1がプリフロップでBB=100に対して200を出して200にRaiseした場合' do
      before do
        @data[:hand_id] = @hand.id
        @data[:user_id] = @user_1.id
        @data[:tern_action] = TernActionRaise.new(200)
        df = DlTernActionForm.new(@data)
        @ds = df.build_service
      end
      it 'call_chipはraise後の額に、min_raise_chipは、新しいcall_chipに(元のcall額とraise後の差額)を足した額' do
        hand = Hand.find(@hand.id)
        expect(hand.call_chip).to eq(100)
        expect(hand.min_raise_chip).to eq(200)
        hand_user = hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.round_total_chip).to eq(0)

        @ds.do!

        hand = Hand.find(@hand.id)
        expect(hand.call_chip).to eq(200)
        expect(hand.min_raise_chip).to eq(300)
        hand_user = hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.round_total_chip).to eq(200)
      end
    end
    context 'プリフロップでcall_chip=100に対してもともと100出していたuser_1がさらに200を上乗せして合計300にRaiseした場合' do
      before do
        @data[:hand_id] = @hand.id
        @data[:user_id] = @user_1.id
        @data[:tern_action] = TernActionRaise.new(200)
        hand_user = @hand.hand_users.where(:user_id => @user_1.id).first
        hand_user.round_total_chip = 100
        hand_user.save!

        df = DlTernActionForm.new(@data)
        @ds = df.build_service
      end
      it 'call_chipはraise後の額に、min_raise_chipは、新しいcall_chipに(元のcall額とraise後の差額)を足した額' do
        hand = Hand.find(@hand.id)
        expect(hand.call_chip).to eq(100)
        expect(hand.min_raise_chip).to eq(200)
        hand_user = hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.round_total_chip).to eq(100)

        @ds.do!

        hand = Hand.find(@hand.id)
        expect(hand.call_chip).to eq(300)
        expect(hand.min_raise_chip).to eq(500)
        hand_user = hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.round_total_chip).to eq(300)
      end
    end
    context 'user_1がプリフロップでmin_raise_chip=1000に対して400を出してall_inした場合' do
      before do
        @hand.call_chip = 500
        @hand.min_raise_chip = 1000
        @hand.save!

        @data[:hand_id] = @hand.id
        @data[:user_id] = @user_1.id
        @data[:tern_action] = TernActionCall.new(400)

        df = DlTernActionForm.new(@data)
        @ds = df.build_service
      end
      it 'call_chipはraise後の額に、min_raise_chipは、新しいcall_chipに(元のcall額とraise後の差額)を足した額' do
        hand = Hand.find(@hand.id)
        expect(hand.call_chip).to eq(500)
        expect(hand.min_raise_chip).to eq(1000)
        hand_user = hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.round_total_chip).to eq(0)

        @ds.do!

        hand = Hand.find(@hand.id)
        expect(hand.call_chip).to eq(500)
        expect(hand.min_raise_chip).to eq(1000)
        hand_user = hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.round_total_chip).to eq(400)
      end
    end
    context 'user_1がプリフロップでmin_raise_chip=1000に対して900を出してall_inした場合' do
      before do
        @hand.call_chip = 500
        @hand.min_raise_chip = 1000
        @hand.save!

        @data[:hand_id] = @hand.id
        @data[:user_id] = @user_1.id
        @data[:tern_action] = TernActionRaise.new(900)

        df = DlTernActionForm.new(@data)
        @ds = df.build_service
      end
      it 'call_chipはraise後の額に、min_raise_chipは、もともとのmin_raise_chipを下回る額でraiseしているため、変化しない' do
        hand = Hand.find(@hand.id)
        expect(hand.call_chip).to eq(500)
        expect(hand.min_raise_chip).to eq(1000)
        hand_user = hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.round_total_chip).to eq(0)

        @ds.do!

        hand = Hand.find(@hand.id)
        expect(hand.call_chip).to eq(900)
        expect(hand.min_raise_chip).to eq(1000)
        hand_user = hand.hand_users.where(:user_id => @user_1.id).first
        expect(hand_user.round_total_chip).to eq(900)
      end
    end
  end
end
