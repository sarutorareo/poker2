class DlTernActionForm
  include ActiveModel::Model

  attr_reader :hand_id, :user_id, :action_kbn, :chip

  # hand_id, user_id, action_kbn, chip  は必須
  validates :hand_id, :user_id, :action_kbn, :chip,presence: true
  validates :action_kbn, inclusion: [
    TernAction::ACT_KBN_NULL,
    TernAction::ACT_KBN_FOLD,
    TernAction::ACT_KBN_CALL,
    TernAction::ACT_KBN_RAISE,
    TernAction::ACT_KBN_ALL_IN
  ] # 数値のみ有効

  # Postパラメータを受け取る
  # (コンストラクタでreceiveを兼ねる)
  def initialize (data)
    @hand_id = data[:hand_id]
    @user_id = data[:user_id]
    @action_kbn = data[:action_kbn]
    @chip = data[:chip]
  end

  # サービスを生成
  def build_service 
    if self.invalid?
      raise ArgumentError, "DlTernActionFormの引数が不正 error=#{self.errors}"
    end
    DlTernActionService.new(@hand_id, @user_id, @action_kbn)
  end

  def tern_user?
    hand = Hand.find_by_id(@hand_id)
    if (hand == nil)
      return false
    end
    return hand.tern_user.id == @user_id
  end
end
