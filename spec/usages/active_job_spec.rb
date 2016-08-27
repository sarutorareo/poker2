require 'spec_helper'
require 'capybara_helper'

describe "travel_to" do
  it '現在時刻が変わる' do
    expect(Date.today).not_to eq(Date.new(2016, 8, 17))
    time = DateTime.new(2016, 8, 1, 12, 0, 0)
    travel_to (time) do
      expect(Date.today).to eq(Date.new(2016, 8, 1))
    end
    expect(Date.today).not_to eq(Date.new(2016, 8, 1))
  end
end
