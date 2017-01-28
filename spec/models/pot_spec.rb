require 'rails_helper'

RSpec.describe Pot, type: :model do
  describe 'user_names' do
    context '誰もいないとき' do
      it '空文字列を返す' do
        pot = Pot.new
        expect(pot.user_names).to eq("")
      end
    end
    context '"jirou"が居るとき' do
      it '"jirou"を返す' do
        pot = Pot.new
        u = User.new
        u.name = 'jirou'
        hu = HandUser.new
        hu.user = u
        pot.hand_users << hu
        expect(pot.user_names).to eq("jirou")
      end
    end
    context '"ichirou"と"jirou"が居るとき' do
      it '"ichirou, jirou"を返す' do
        pot = Pot.new
        u = User.new
        u.name = 'ichirou'
        hu = HandUser.new
        hu.user = u
        pot.hand_users << hu
        u = User.new
        u.name = 'jirou'
        hu = HandUser.new
        hu.user = u
        pot.hand_users << hu
        expect(pot.user_names).to eq("ichirou, jirou")
      end
    end
  end
end
