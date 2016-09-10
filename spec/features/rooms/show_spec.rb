#require 'support/wait_for_ajax'
require 'spec_helper'
require 'capybara_helper'
#include Capybara::DSL
#include WaitForAjax

describe "入室" do
  before {
    @user1 = FactoryGirl.create(:user, {:name=>'test_user_1'})
    @user2 = FactoryGirl.create(:user, {:name=>'test_user_2'})
    visit '/'
  }
  context "ユーザーを選択せず入室するとき", js:true  do
    it 'room#showに遷移して、先頭のユーザー名が表示される' do
      find('button#room_1').click
      expect(find('h1', text: 'Chat room Room001')).not_to eq(nil)
      expect(find('#user_name', text: '(test_user_1)')).not_to eq(nil)
    end
  end
  context "ユーザーを選択して入室するとき", js:true  do
    before {
      select "2", from: "user_select"
      find('button#room_2').click
    }
 
    it 'room#showに遷移して、先頭のユーザー名が表示される' do
      expect(find('h1', text: 'Chat room Room002')).not_to eq(nil)
      expect(find('#user_name', text: '(test_user_2)')).not_to eq(nil)
    end
  end
end
describe "メッセージ入力", js: true do
  before { 
    @user = FactoryGirl.create(:user)
    visit "/"
    find('button#room_1').click
  }
      
  context "textを入力して送信ボタンを押す"  do
    before { 
      fill_in 'input_message', with: 'message_for_test'
    }
 
    it 'text入力欄が空になる' do
      click_button '送信'
      #wait_for_ajax
      expect(find('input#input_message').value).to eq('')
    end
  end
end

describe "ハンド開始" do
  pending "add some examples to (or delete) #{__FILE__}"
  before do
    # 入室
    @user1 = FactoryGirl.create(:user, {:name=>'test_user_1'})
    visit "/"
    select "1", from: "user_select"
    find('button#room_1').click
  end
      
  context "プレイヤーが一人"  do
    it "ハンド開始ボタンを押す"  do
  pending "add some examples to (or delete) #{__FILE__}"
      click_button 'ハンド開始'
      expect(Hand.count).to eq(1)
      # expect(HandUser.count).to eq(1)
    end
  end
end
