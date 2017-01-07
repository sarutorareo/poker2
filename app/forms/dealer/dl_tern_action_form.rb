class DlTernActionForm < DlHandFormBase
  include ActiveModel::Model

  attr_reader :user_id, :tern_action

  # hand_id, user_id, action_kbn, chip  は必須
  validates :user_id, :tern_action, presence: true
  validate do
    if tern_action.kind_of?(TernActionNull)  
      errors.add(:tern_action, "TernActionNull is invalid")
    end
  end

  # Postパラメータを受け取る
  # (コンストラクタでreceiveを兼ねる)
  def initialize (data)
    super(data)
    @user_id = data[:user_id]
    @tern_action = data[:tern_action]
  end

  # サービスを生成
  def build_service 
    check_valid_and_raise
    DlTernActionService.new(@hand_id, @user_id, @tern_action)
  end

  def tern_user?
    hand = Hand.find_by_id(@hand_id)
    if hand == nil
      return false
    end
    hand.tern_user.id == @user_id
  end
end
