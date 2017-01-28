class DlApplyPotsForm < DlHandFormBase
  include ActiveModel::Model

  attr_reader :pots

  validates :pots, presence: true

  def initialize (data)
    super(data)
    @pots = data.fetch(:pots, nil)
  end

  def build_service 
    check_valid_and_raise
    DlApplyPotsService.new(@hand_id, @pots)
  end
end

