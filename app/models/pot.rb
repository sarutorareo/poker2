class Pot
  include ActiveModel::Model

  attr_accessor :hand_users, :chip

  def initialize
    @chip = 0
    @hand_users = []
  end
end
