require 'rails_helper'

RSpec.describe Hand, type: :model do
  describe "initialize!" do
    before do
      @hand = Hand.new
    end
    it 'デフォルトはプリフロップ' do
      expect(@hand.betting_round).to eq(Hand::BR_PREFLOP)
      expect(@hand.board.count).to eq(0)
      expect(@hand.big_blind).to eq(100)
      expect(@hand.call_chip).to eq(100)
      expect(@hand.min_raise_chip).to eq(200)
    end
  end
  describe "betting_round_str!" do
    before do
      @hand = Hand.new
    end
    it 'ベッティングラウンドを文字列で表す' do
      @hand.betting_round = Hand::BR_PREFLOP
      expect(@hand.betting_round_str).to eq('preflop')
      @hand.betting_round = Hand::BR_FLOP
      expect(@hand.betting_round_str).to eq('flop')
      @hand.betting_round = Hand::BR_TURN
      expect(@hand.betting_round_str).to eq('turn')
      @hand.betting_round = Hand::BR_RIVER
      expect(@hand.betting_round_str).to eq('river')
    end
  end
  describe "create_hand_users!" do
    before do
      @user_1 = FactoryGirl.create(:user, :chip=>101)
      @user_2 = FactoryGirl.create(:user, :chip=>102)
      @room = Room.find(1)
    end
    context "roomにユーザーが二人いる場合" do
      before do
        @room.users << @user_1
        @room.users << @user_2
        button_user = @user_1
        @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      end
      it "二人分hand_userが作られる" do
        @hand.create_hand_users!(@room.get_room_user_ids_sorted_by_user_type_enter_time)
        expect(@hand.hand_users.count).to eq(2)
        # "DBに値が保存されている"
        expect(HandUser.count(:hand_id == @hand.id)).to eq(2)
        # chipは0
        expect(HandUser.find_by_user_id(@user_1.id).hand_total_chip).to eq(0)
        expect(HandUser.find_by_user_id(@user_2.id).hand_total_chip).to eq(0)
      end
    end
    context "roomにユーザーが一人もいない場合" do
      before do
        button_user = @user_1
        @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
      end
      it "長さ0のhand_userが作られる" do
        @hand.create_hand_users!(@room.get_room_user_ids_sorted_by_user_type_enter_time)
        expect(@hand.hand_users.count).to eq(0)
      end
    end
  end
  describe "_get_tern_user_index" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      @button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: @button_user, tern_user: @button_user
    end
    context "user_1, user_2の順に追加" do
      before do
        @hand.users << @user_1
        @hand.users << @user_2
      end
      context "user_1の場合" do 
        before do
          @hand.tern_user = @user_1
        end
        it "インデックス = 0" do
          expect(@hand.send(:_get_tern_user_index)).to eq(0)
        end
      end
      context "user_2の場合" do 
        before do
          @hand.tern_user = @user_2
        end
        it "インデックス = 1" do
          expect(@hand.send(:_get_tern_user_index)).to eq(1)
        end
      end
    end
    context "user_2, user_1の順に追加" do
      before do
        @hand.users << @user_2
        @hand.users << @user_1
      end
      context "user_1の場合" do 
        before do
          @hand.tern_user = @user_1
        end
        it "インデックス = 1" do
          expect(@hand.send(:_get_tern_user_index)).to eq(1)
        end
      end
      context "user_2の場合" do 
        before do
          @hand.tern_user = @user_2
        end
        it "インデックス = 0" do
          expect(@hand.send(:_get_tern_user_index)).to eq(0)
        end
      end
    end
  end
  describe "start_hand" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @user_3 = FactoryGirl.create(:user)
      @room = Room.find(1)
      @room.users << @user_1
      @room.users << @user_2
      @room.users << @user_3
      @button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: @button_user, tern_user: @user_2
    end
    context "start_handをしたら" do 
      it "handのusersが作られる" do
        expect(@hand.users.count).to eq(0)
        @hand.create_hand_users!(@room.get_room_user_ids_sorted_by_user_type_enter_time )
        expect(@hand.users.count).to eq(3)
        expect(@hand.users[0].id).to eq(@user_1.id)
        expect(@hand.users[1].id).to eq(@user_2.id)
        expect(@hand.users[2].id).to eq(@user_3.id)

        expect(@hand.button_user.id).to eq(@user_1.id)
        expect(@hand.tern_user.id).to eq(@user_2.id)
      end
    end
  end
  describe "rotate_tern" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @user_3 = FactoryGirl.create(:user)
      @room = Room.find(1)
      @room.users << @user_1
      @room.users << @user_2
      @room.users << @user_3
      @button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: @button_user, tern_user: @user_2
      @hand.create_hand_users!(@room.get_room_user_ids_sorted_by_user_type_enter_time )
    end
    context "誰もアクションしていない, 二人目の次を探すとき" do
      before do
        @hand.tern_user = @user_2
      end
      context "Create直後" do
        it "user_2がターンユーザー" do
          expect(@hand.tern_user.id).to eq(@user_2.id)
        end
      end
      context "start_hand後、rotateをしたら" do
        it "３人目の人がターンユーザー" do
          @hand.rotate_tern!
          expect(@hand.tern_user.id).to eq(@user_3.id)
        end
      end
      context "start_hand後、rotate, さらにrotateをしたら" do
        it "1人目の人がターンユーザー" do
          @hand.create_hand_users!(@room.get_room_user_ids_sorted_by_user_type_enter_time )
          @hand.rotate_tern!
          expect(@hand.tern_user.id).to eq(@user_3.id)
          @hand.rotate_tern!
          expect(@hand.tern_user.id).to eq(@user_1.id)
        end
      end
    end
    context "foldした人がいるとき" do
      context "１人目の次を探すとき" do
        before do
          @hand.tern_user = @user_1
        end
        context "Create直後" do
          it "user_1がターンユーザー" do
            expect(@hand.tern_user.id).to eq(@user_1.id)
          end
        end
        context "2人目がFoldしていたら" do
          before do
            hu = @hand.hand_users.select{|hu| hu.user_id == @user_2.id}.first
            hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_FOLD)
          end
          it "３人目の人がターンユーザー" do
            @hand.rotate_tern!
            expect(@hand.tern_user.id).to eq(@user_3.id)
          end
        end
      end
      context "2人目の次を探すとき" do
        before do
          @hand.tern_user = @user_2
        end
        context "Create直後" do
          it "user_2がターンユーザー" do
            expect(@hand.tern_user.id).to eq(@user_2.id)
          end
        end
        context "3人目がFoldしていたら" do
          before do
            hu = @hand.hand_users.select{|hu| hu.user_id == @user_3.id}.first
            hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_FOLD)
          end
          it "1人目の人がターンユーザー" do
            @hand.rotate_tern!
            expect(@hand.tern_user.id).to eq(@user_1.id)
          end
        end
      end
    end
    context "all_inした人がいるとき" do
      context "１人目の次を探すとき" do
        context "2人目がAllInしていたら" do
          before do
            hu = @hand.hand_users.select{|hu| hu.user_id == @user_2.id}.first
            hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL_ALL_IN, 200)
          end
          it "３人目の人がターンユーザー" do
            @hand.rotate_tern!
            expect(@hand.tern_user.id).to eq(@user_3.id)
          end
        end
      end
      context "2人目の次を探すとき" do
        before do
          @hand.tern_user = @user_2
        end
        context "3人目がFoldしていたら" do
          before do
            hu = @hand.hand_users.select{|hu| hu.user_id == @user_3.id}.first
            hu.last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL_ALL_IN, 300)
          end
          it "1人目の人がターンユーザー" do
            @hand.rotate_tern!
            expect(@hand.tern_user.id).to eq(@user_1.id)
          end
        end
      end
    end
  end
  describe 'get_max_order' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: button_user
    end
    context "0人しかいないとき" do
      it "max = 0" do
        expect(@hand.get_max_hand_user_order).to eq(0)
      end
    end
    context "1人いるとき" do
      before do
        @hand.users << @user_1
      end
      it "max = 1" do
        expect(@hand.get_max_hand_user_order).to eq(1)
      end
    end
    context "2人いるとき" do
      before do
        @hand.users << @user_1
        @hand.users << @user_2
      end
      it "max = 2" do
        expect(@hand.get_max_hand_user_order).to eq(2)
      end
    end
  end
  describe 'saveされたらjobをenqueue' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
    end
    context "createしてsave" do
      before do
        @hand = Hand.new room_id: @room.id, button_user: @user_1, tern_user: @user_1
      end
      it 'StartHandBloadcastJobがenqueueされている' do
        time = Time.current
        travel_to(time) do
          assertion = {
            job: BroadcastHandUsersJob,
            #args: @room_user,
            at: (time + WAIT_TIME_HAND_USERS_BROAD_CAST_JOB).to_i
          }
          assert_enqueued_with(assertion) { 
            @hand.save!
          }
          assertion = {
            job: BroadcastRoomUsersJob,
            #args: @room_user,
            at: (time + WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB).to_i
          }
          assert_enqueued_with(assertion) { 
            @hand.save!
          }
        end
      end
    end
    context "updateしてsave" do
      before do
        @hand = Hand.new room_id: @room.id, button_user: @user_1, tern_user: @user_1
        @hand.save!
      end
      it 'StartHandBloadcastJobがenqueueされている' do
        time = Time.current
        travel_to(time) do
          assertion = {
            job: BroadcastHandUsersJob,
            #args: @room_user,
            at: (time + WAIT_TIME_HAND_USERS_BROAD_CAST_JOB).to_i
          }
          assert_enqueued_with(assertion) { 
            @hand.tern_user = @user_2
            @hand.save!
          }
          assertion = {
            job: BroadcastRoomUsersJob,
            #args: @room_user,
            at: (time + WAIT_TIME_ROOM_USERS_BROAD_CAST_JOB).to_i
          }
          assert_enqueued_with(assertion) { 
            @hand.tern_user = @user_2
            @hand.save!
          }
        end
      end
    end
  end

  describe 'tern_user?' do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: @user_1
    end
    context 'tern_userなら' do
      before do
      end
      it 'trueを返す' do
        expect(@hand.tern_user?(@user_1.id)).to eq(true)
      end
    end
    context 'tern_userではないユーザーのアクションなら' do
      before do
      end
      it 'falseを返す' do
        expect(@hand.tern_user?(@user_2.id)).to eq(false)
      end
    end
  end
  describe "rotated_all?" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @room = Room.find(1)
      button_user = @user_1
      @hand = Hand.create! room_id: @room.id, button_user: button_user, tern_user: @user_1
      @hand.users << @user_1
      @hand.users << @user_2
    end
    context '全員回ってなかったら' do 
      before do
      end
      it 'falseを返す' do
        expect(@hand.rotated_all?).to eq(false)
      end
    end
    context '全員回ったら' do 
      before do
      end
      it 'trueを返す' do
        @hand.hand_users.each do |hu|
          hu.last_action_kbn = TernAction::ACT_KBN_FOLD
        end
        expect(@hand.rotated_all?).to eq(true)
      end
    end
  end
  describe "deckとdeck_str" do
    context 'new直後' do
      it '52枚分のカードを持っている' do
        hand = Hand.new
        expect(hand.deck.count).to eq(52)
      end
    end
    context 'createしてからsaveしてロードする場合' do
      before do
        @user_1 = FactoryGirl.create(:user)
        @room = Room.find(1)
        @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_1
      end
      it 'create直後は52枚' do
        expect(@hand.deck.count).to eq(52)
      end
      it 'saveしてロードすると、52枚が復活する' do
        @hand.save!
        @hand = Hand.find(@hand.id)
        expect(@hand.deck.count).to eq(52)
        expect(@hand.deck_str.length).to eq(52*2)
      end
    end
    context 'create,カード削除, saveしてからロードした場合' do
      before do
        @user_1 = FactoryGirl.create(:user)
        @room = Room.find(1)
        @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_1
      end
      it 'カードを抜いてからsaveしてロードすると、deckの状態が復元する' do
        (1..50).each do 
          @hand.deck.shift
        end
        @hand.save!
        @hand = Hand.find(@hand.id)
        expect(@hand.deck_str).to eq('DQDK')
        expect(@hand.deck.to_s).to eq('DQDK')
      end
    end
  end
  describe "boardとboard_str" do
    context 'new直後' do
      it '0枚分のカードを持っている' do
        hand = Hand.new
        expect(hand.board.count).to eq(0)
      end
    end
    context 'create,カード追加, saveしてからロードした場合' do
      before do
        @user_1 = FactoryGirl.create(:user)
        @room = Room.find(1)
        @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_1
      end
      it 'カードを抜いてからsaveしてロードすると、deckの状態が復元する' do
        (1..3).each do 
          @hand.board << @hand.deck.shift
        end
        @hand.save!
        @hand = Hand.find(@hand.id)
        expect(@hand.board_str).to eq('SAS2S3')
        expect(@hand.board.to_s).to eq('SAS2S3')
      end
    end
  end
  describe 'next_betting_round' do
    before do
      @hand = Hand.new
    end
    it 'trueを返す' do
      @hand.betting_round = Hand::BR_PREFLOP
      @hand.next_betting_round
      expect(@hand.betting_round).to eq(Hand::BR_FLOP)
    end
  end
  describe 'get_hand_users_to_reset_by_raise' do
    before do
      @hand = Hand.new
      @user_1 = User.new(:id => 1, :name => 'test1')
      @user_2 = User.new(:id => 2, :name => 'test2')
      @user_3 = User.new(:id => 3, :name => 'test3')
      @user_4 = User.new(:id => 4, :name => 'test4')
      @user_5 = User.new(:id => 5, :name => 'test5')
      @user_6 = User.new(:id => 6, :name => 'test6')
      @hand.users << @user_1
      @hand.users << @user_2
      @hand.users << @user_3
      @hand.users << @user_4
      @hand.users << @user_5
      @hand.users << @user_6
      @hand.hand_users[0].last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_RAISE, 200)
      @hand.hand_users[1].last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL, 200)
      @hand.hand_users[2].last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_FOLD)
      @hand.hand_users[3].last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_CALL_ALL_IN, 200)
      @hand.hand_users[4].last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_RAISE_ALL_IN, 400)
      @hand.hand_users[5].last_action = TernAction.new_from_kbn_and_chip(TernAction::ACT_KBN_RAISE, 800)
    end
    it 'RAISEした人、FOLD, CALL_ALL_IN, RAISE_ALL_INを除いたユーザーのみが抽出される' do
      hand_users = @hand.get_hand_users_to_reset_by_raise(@user_6.id)
      expect(hand_users.size).to eq(2)
      expect(hand_users[0].user_id).to eq(@user_1.id)
      expect(hand_users[0].last_action.kbn).to eq(TernAction::ACT_KBN_RAISE)
      expect(hand_users[1].user_id).to eq(@user_2.id)
      expect(hand_users[1].last_action.kbn).to eq(TernAction::ACT_KBN_CALL)
    end
  end
  describe "raise_chip" do
    context "new直後の場合" do
      before do
        @hand = Hand.new
      end
      it "call_chip == 100, min_raise_chip == 200" do
        expect(@hand.call_chip).to eq(100)
        expect(@hand.min_raise_chip).to eq(200)
      end
    end
    context "200にraiseした場合" do
      before do
        @hand = Hand.new
      end
      it "call_chip == 200, min_raise_chip == 300" do
        @hand.raise_chip(200)
        expect(@hand.call_chip).to eq(200)
        expect(@hand.min_raise_chip).to eq(300)
      end
    end
    context "200にraiseしたあと、更に300にraiseした場合" do
      before do
        @hand = Hand.new
      end
      it "call_chip == 300, min_raise_chip == 400" do
        @hand.raise_chip(200)
        @hand.raise_chip(300)
        expect(@hand.call_chip).to eq(300)
        expect(@hand.min_raise_chip).to eq(400)
      end
    end
    context "150にraiseしたあと、更に300にraiseした場合" do
      before do
        @hand = Hand.new
      end
      it "call_chip == 300, min_raise_chip == 450" do
        @hand.raise_chip(150)
        @hand.raise_chip(300)
        expect(@hand.call_chip).to eq(300)
        expect(@hand.min_raise_chip).to eq(450)
      end
    end
    context "少ない額でall_inした場合" do
      context "もともと100/200のところを50でall_in場合" do
        before do
          @hand = Hand.new
        end
        it "call_chip == 100, min_raise_chip == 200" do
          @hand.raise_chip(50)
          expect(@hand.call_chip).to eq(100)
          expect(@hand.min_raise_chip).to eq(200)
        end
      end
      context "500にraiseした(500/900)あと、更に899にraiseした場合" do
        before do
          @hand = Hand.new
        end
        it "call_chip == 800, min_raise_chip == 900(もともとのmin_raise_chipよりも下回る額でraiseされた場合はmin_raise_chipは変化しない)" do
          @hand.raise_chip(500)
          expect(@hand.call_chip).to eq(500)
          expect(@hand.min_raise_chip).to eq(900)
          @hand.raise_chip(899)
          expect(@hand.call_chip).to eq(899)
          expect(@hand.min_raise_chip).to eq(900)
        end
      end
      context "500にraiseした(500/900)あと、更に900にraiseした場合" do
        before do
          @hand = Hand.new
        end
        it "call_chip == 800, min_raise_chip == 900(もともとのmin_raise_chipよりも下回る額でraiseされた場合はmin_raise_chipは変化しない)" do
          @hand.raise_chip(500)
          expect(@hand.call_chip).to eq(500)
          expect(@hand.min_raise_chip).to eq(900)
          @hand.raise_chip(900)
          expect(@hand.call_chip).to eq(900)
          expect(@hand.min_raise_chip).to eq(1300)
        end
      end
    end
  end
end
