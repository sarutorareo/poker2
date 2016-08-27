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
    it 'room_usersにレコードが追加されている' do
      room_user = RoomUser.where(:room_id=>1, :user_id=>@user1.id).first
      expect(room_user).to eq(nil)

      find('button#room_1').click

      room_user = RoomUser.where(:room_id=>1, :user_id=>@user1.id).first
      expect(room_user).not_to eq(nil)
    end
    it 'EnteredBloadcastJobがenqueueされている' do
      time = Time.current
      travel_to(time) do
        assertion = {
          job: EnteredBroadcastJob,
          #args: @room_user,
          at: (time + WAIT_TIME_ENTERED_BROAD_CAST_JOB).to_i
        }
        assert_enqueued_with(assertion) { find('button#room_1').click }
      end
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

##    context "textを入力して送信ボタンを押す"  do
##      before { 
##        fill_in 'input_message', with: 'message_for_test'
##      }
##  
##      it '#messageに入力した文字列が現れる' do
##        page.save_screenshot('/home/sarutorareo/github/poker2/spec/pics/before_clicked.png')
##        expect(Message.count).to eq(1)
##        expect(page).to have_selector('div#message', count: 1)
##        click_button '送信'
##        #wait_for_ajax
##  
##        page.save_screenshot('/home/sarutorareo/github/poker2/spec/pics/after_clicked.png')
##        expect(page).to have_css('div#text_messages')
##        find('#text_messages', match: :first)
##        #until has_css?('#message'); end
##        find('div#message', match: :first)
##        expect(Message.count).to eq(2)
##        expect(page).to have_selector('div#message', count: 2)
##        expect(page).to have_css('p', text: 'from_js')
##  #      expect(page).to have_css('p', text: 'message_for_test')
##  #      # この書き方は無効 expect(page).to have_css('input#input_message', text: 'from_js')
##      end
##    end
##  end
## end
