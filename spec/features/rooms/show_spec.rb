require 'support/wait_for_ajax'
require 'spec_helper'

describe ' トップページ' do
  specify ' タイトルを表示' do
    visit '/' #root_path
    expect(page).to have_css('h1', text: 'Chat room')
  end
end

describe "メッセージ入力", js: true do
  before { visit '/' }
      
  context "textを入力して送信ボタンを押す"  do
    include WaitForAjax
    before { 
      fill_in 'input_message', with: 'test_message'
      click_button '送信'
    }
    it 'text入力欄が空になる' do
      wait_for_ajax
      expect(find('input#input_message').value).to eq('')
    end
#    it '#messageに入力した文字列が現れる'
#      wait_for_ajax
#      expect(page).to have_css('div#messages')
#      find('#messages', match: :first)
#      #until has_css?('#message'); end
#      find('#message', match: :first)
#      expect(page).to have_css('p', text: 'from_js')
#      within('div#messages') do
#        expect(page).to have_css('p', text: 'test_message2xxxx')
#      end
#      # この書き方は無効 expect(page).to have_css('input#input_message', text: 'from_js')
#    end
  end
end
