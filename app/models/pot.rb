class Pot
  include ActiveModel::Model

  attr_accessor :hand_users, :chip

  def initialize()
    @chip = 0
    @hand_users = []
  end

  def self.new_from_values(chip, hand_users)
    pot = Pot.new
    pot.chip = chip
    pot.hand_users = hand_users
    pot
  end

  def user_names
    hand_users.map{|hu| hu.user.name}.join(', ')
  end
end
