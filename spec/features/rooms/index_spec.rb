#require 'support/wait_for_ajax'
require 'spec_helper'
require 'capybara_helper'
#include WaitForAjax

describe ' トップページ' do
  describe 'ルームの表示' do
    it ' タイトルを表示' do
      visit '/' #root_path
      expect(page).to have_css('th', text: '部屋名')
    end
  end
  describe 'ユーザーの表示' do
    before do
      FactoryGirl.create(:user, {:name=>'test_user_1'})
    end
    it ' タイトルを表示' do
      visit '/' #root_path

      #page.save_screenshot('/home/sarutorareo/github/poker2/spec/pics/visit_root.png')
      expect(all('#user_select > option').length).to eq(1)
      expect(all('#user_select > option')[0][:value]).to eq("1")
      expect(all('#user_select > option')[0][:text]).to eq("test_user_1")
    end
  end
end
