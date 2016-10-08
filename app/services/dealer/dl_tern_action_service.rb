class DlTernActionService
  def initialize(hand_id, user_id, action_kbn)
    @hand_id = hand_id
    @user_id = user_id
    @action_kbn = action_kbn
  end

  def do!()
    hand = Hand.find(@hand_id)
    unless hand.tern_user?(@user_id)
      return
    end

    hand_user = hand.hand_users.where(:user_id => @user_id).first
    if hand_user.blank? 
      raise "hand_user not found (hand_id=#{@hand_id}, user_id=#{@user_id}"
    end
    ApplicationRecord.transaction do
      hand_user.last_action_kbn = @action_kbn
      hand.rotate_tern!
      hand_user.save!
      hand.save!
    end
  end
end
