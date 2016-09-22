class DlTernActionForm
  include ActiveModel::Model

  attr_reader :hand_id, :user_id, :action_kbn

  # user_idは必須
  validates :hand_id, :user_id, :action_kbn, presence: true
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
    @hand_id = data['hand_id']
    @user_id = data['user_id']
    @action_kbn = data['action_kbn']
  end

  # サービスを生成
  def build_service 
    if self.invalid?
      raise ArgumentError, "DlTernActionFormの引数が不正 error=#{self.errors}"
    end
    DlTernActionService.new(@hand_id, @user_id, @action_kbn)
  end
end
