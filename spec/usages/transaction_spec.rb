require 'spec_helper'
require 'capybara_helper'

describe "transaction" do
  before do
    @user_1 = FactoryGirl.create(:user)
    @user_2 = FactoryGirl.create(:user)
    @user_3 = FactoryGirl.create(:user)
    @room = Room.find(1)

    @hand = Hand.create! room_id: @room.id, button_user: @user_1, tern_user: @user_2

    @user_1.name = 'before_user'
    @before_user_name = @user_1.name
    @hand.tern_user = @user_1
    @user_1.save!
    @hand.save!
  end
  context 'commitされる場合' do
    it '変更した結果がロードされる' do
      ApplicationRecord.transaction do
        @user_1.name = 'xxxx1'
        @hand.tern_user = @user_2
        @user_1.save!
        @hand.save!
      end
      @user_1 = User.find(@user_1.id)
      @hand = Hand.find(@hand.id)
      expect(@user_1.name).to eq('xxxx1')
      expect(@hand.tern_user.id).to eq(@user_2.id)
    end
  end

  context 'rollbackされる場合' do
    it '変更前の結果ロードされる' do
      begin
        ApplicationRecord.transaction do
          @user_1.name = 'xxxx2'
          @hand.tern_user = @user_2
          @user_1.save!
          raise 'test'
          @hand.save!
        end
      rescue 
      end
      @user_1 = User.find(@user_1.id)
      @hand = Hand.find(@hand.id)
      expect(@user_1.name).not_to eq('xxxx2')
      expect(@hand.tern_user.id).to eq(@user_1.id)
    end
  end
  context 'nest して、途中の一つがrollbackされる場合' do
    context '内側がrollbackされる場合' do
      it '全トランザクションがロールバックされる' do
        begin
          ApplicationRecord.transaction do
            @user_1.name = 'xxxx2'
            @user_1.save!

            ApplicationRecord.transaction do
              @hand.tern_user = @user_2
              raise 'test'
              @hand.save!
            end
          end
        rescue 
        end
        @user_1 = User.find(@user_1.id)
        @hand = Hand.find(@hand.id)
        expect(@user_1.name).not_to eq('xxxx2')
        expect(@user_1.name).to eq(@before_user_name)
        expect(@hand.tern_user.id).to eq(@user_1.id)
      end
    end
    context '外側がrollbackされる場合' do
      it '全トランザクションがロールバックされる' do
        begin
          ApplicationRecord.transaction do
            @user_1.name = 'xxxx2'
            @user_1.save!

            ApplicationRecord.transaction do
              @hand.tern_user = @user_2
              @hand.save!
            end
            raise 'test'
          end
        rescue 
        end
        @user_1 = User.find(@user_1.id)
        @hand = Hand.find(@hand.id)
        expect(@user_1.name).not_to eq('xxxx2')
        expect(@user_1.name).to eq(@before_user_name)
        expect(@hand.tern_user.id).to eq(@user_1.id)
      end
    end
    context '兄弟がrollbackされる場合' do
      it '全トランザクションはロールバックされる' do
        begin
          ApplicationRecord.transaction do
            @user_1.name = 'xxxx2'
            @user_1.save!

            ApplicationRecord.transaction do
              @hand.tern_user = @user_3
              @hand.save!
            end
            ApplicationRecord.transaction do
              @hand.tern_user = @user_2
              @hand.save!
              raise 'test'
            end
          end
        rescue 
        end
        @user_1 = User.find(@user_1.id)
        @hand = Hand.find(@hand.id)
        expect(@user_1.name).not_to eq('xxxx2')
        expect(@user_1.name).to eq(@before_user_name)
        expect(@hand.tern_user.id).to eq(@user_1.id)
      end
    end
    context '兄弟がrollback, 例外をレスキューされる場合' do
      it 'レスキューされたトランザクション以外はコミットされる' do
        ApplicationRecord.transaction do
          @user_1.name = 'xxxx2'
          @user_1.save!

          ApplicationRecord.transaction do
            begin
              @hand.tern_user = @user_2
              @hand.save!
              raise 'test'
            rescue 
            end
          end
          ApplicationRecord.transaction do
            @hand.tern_user = @user_3
            @hand.save!
          end
        end
        @user_1 = User.find(@user_1.id)
        @hand = Hand.find(@hand.id)
        expect(@user_1.name).to eq('xxxx2')
        expect(@hand.tern_user.id).to eq(@user_3.id)
      end
    end
  end
end
