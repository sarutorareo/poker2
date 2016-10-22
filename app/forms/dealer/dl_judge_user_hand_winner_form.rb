class DlJudgeUserHandWinnerForm < DlHandFormBase
  include ActiveModel::Model

  def initialize (data)
    super(data)
  end

  def build_service 
    check_valid_and_raise

    hand = Hand.find(@hand_id)
    if hand.blank?
      raise ArgumentError, "hand_id '#{@hand_id}' is not exists"
    end
    hand_users = hand.hand_users.select{|hu| hu.last_action.active?}
    DlJudgeUserHandWinnerService.new(hand_users)
  end
end

