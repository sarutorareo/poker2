class DlTernActionService
  def initialize(hand_id, user_id, tern_action)
    @hand_id = hand_id
    @user_id = user_id
    @tern_action = tern_action
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
      hand_user.last_action = @tern_action
      hand.rotate_tern!
      hand_user.save!
      hand.save!
    end
  end
end
