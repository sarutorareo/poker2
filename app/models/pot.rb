class Pot
  include ActiveModel::Model

  attr_accessor :hand_users, :chip

  def initialize
    @chip = 0
    @hand_users = []
  end

  def user_names
    hand_users.map{|hu| hu.user.name}.join(', ')
  end
end
