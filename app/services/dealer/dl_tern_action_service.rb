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
    user = User.find(@user_id)
    diff_chip = hand_user.hand_total_chip
    if @tern_action.chip > 0 && @tern_action.chip >= user.chip
      user.chip = 0
      if @tern_action.chip <= hand.call_chip
        @tern_action = TernActionCallAllIn.new(@tern_action.chip)
      else
        @tern_action = TernActionRaiseAllIn.new(@tern_action.chip)
      end
    else
      user.chip -= @tern_action.chip
    end
    hand_user.hand_total_chip += @tern_action.chip
    hand_user.last_action = @tern_action
    ApplicationRecord.transaction do
      hand.rotate_tern!
      user.save!
      hand_user.save!
      hand.save!
    end
  end
end
