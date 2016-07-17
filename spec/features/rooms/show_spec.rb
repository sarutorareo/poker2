require 'support/wait_for_ajax'
require 'spec_helper'
include Capybara::DSL
include WaitForAjax

describe ' トップページ' do
  it ' タイトルを表示' do
    visit '/' #root_path
    expect(page).to have_css('h1', text: 'Chat room')
  end
end

describe "メッセージ入力", js: true do
 before { visit '/' }
     
 context "textを入力して送信ボタンを押す"  do
   before { 
     fill_in 'input_message', with: 'message_for_test'
   }

   it 'text入力欄が空になる' do
     click_button '送信'
     wait_for_ajax
     expect(find('input#input_message').value).to eq('')
   end
   context "textを入力して送信ボタンを押す2"  do
     before { 
       fill_in 'input_message', with: 'message_for_test'
     }
 
     it '#messageに入力した文字列が現れる' do
       page.save_screenshot('/home/sarutorareo/github/poker2/spec/pics/before_clicked.png')
       expect(Message.count).to eq(1)
       expect(page).to have_selector('div#message', count: 1)
       click_button '送信'
       wait_for_ajax
 
       page.save_screenshot('/home/sarutorareo/github/poker2/spec/pics/after_clicked.png')
       expect(page).to have_css('div#messages')
       find('#messages', match: :first)
       #until has_css?('#message'); end
       find('div#message', match: :first)
       expect(Message.count).to eq(2)
       expect(page).to have_selector('div#message', count: 2)
       expect(page).to have_css('p', text: 'from_js')
 #      expect(page).to have_css('p', text: 'message_for_test')
 #      # この書き方は無効 expect(page).to have_css('input#input_message', text: 'from_js')
     end
   end
 end
end
