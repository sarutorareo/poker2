class DlJudgeUserHandWinnerForm < DlHandFormBase
  include ActiveModel::Model

  attr_reader :hand_user_ids

  validates :hand_user_ids, presence: true

  def initialize (data)
    super(data)
    @hand_user_ids = data.fetch(:hand_user_ids, nil)
  end

  def build_service 
    check_valid_and_raise

    hand = Hand.find(@hand_id)
    if hand.blank?
      raise ArgumentError, "hand_id '#{@hand_id}' is not exists"
    end
    DlJudgeUserHandWinnerService.new(hand.hand_users.select{|hu| hand_user_ids.include?(hu.user_id)})
  end
end

