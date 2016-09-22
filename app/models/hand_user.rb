class HandUser < ApplicationRecord
  belongs_to :hand
  belongs_to :user
  before_create { 
    _set_order
    _set_chip
  }

  def last_action_str
    return _act_kbn_to_str(self.last_action_kbn)
  end

private
  def _set_order
    max_order = self.hand.get_max_hand_user_order
    self.tern_order = max_order + 1
  end
  def _set_chip
    self.chip = self.user.chip
  end
  def _act_kbn_to_str(act_kbn)
    return case act_kbn
      when TernAction::ACT_KBN_FOLD then 'fold'
      when TernAction::ACT_KBN_CALL then 'call'
      when TernAction::ACT_KBN_RAISE then 'raise'
      when TernAction::ACT_KBN_ALL_IN then 'all_in'
      when TernAction::ACT_KBN_NULL then '-'
      else raise 'invalid user_action_kbn'
    end
  end
end
