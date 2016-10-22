class DlHandFormBase
  include ActiveModel::Model

  attr_reader :hand_id

  # hand_id は必須
  validates :hand_id, presence: true

  def initialize (data)
    @hand_id = data[:hand_id]
  end

  def build_service 
    raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
  end

  def check_valid_and_raise
    if self.invalid?
      raise ArgumentError, "#{self.class}の引数が不正 error=#{self.errors}"
    end
  end
end

