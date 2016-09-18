class Dealer < ApplicationRecord
  def self.user_action(hand, user_id, action_kbn)
    hand_user = hand.hand_users.where(:user_id => user_id).first
    if hand_user.blank? 
      raise "hand_user not found (hand_id=#{hand_id}, user_id=#{user_id}"
    end
    hand_user.set_last_action_kbn!(action_kbn)
    hand.rotate_tern!
  end
end
