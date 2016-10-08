class DlJudgeActionWinnerForm
  include ActiveModel::Model

  attr_reader :hand_id

  # hand_id は必須
  validates :hand_id, presence: true

  def initialize (data)
    @hand_id = data[:hand_id]
  end

  def build_service 
    if self.invalid?
      raise ArgumentError, "DlJugdeActionWinnerFormの引数が不正 error=#{self.errors}"
    end

    DlJudgeActionWinnerService.new(@hand_id)
  end
end

