class DlNextBettingRoundForm < DlHandFormBase
  include ActiveModel::Model

  def initialize (data)
    super(data)
  end

  def build_service 
    check_valid_and_raise
    DlNextBettingRoundService.new(@hand_id)
  end
end

