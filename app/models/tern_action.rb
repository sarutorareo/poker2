class TernAction
  include ActiveModel::Model
  attr_reader :chip

  ACT_KBN_NULL = nil
  ACT_KBN_FOLD = 0
  ACT_KBN_CALL = 1
  ACT_KBN_RAISE = 2
  ACT_KBN_CALL_ALL_IN = 3
  ACT_KBN_RAISE_ALL_IN = 4

  def initialize
    @chip = 0
  end

  def kbn 
    raise 'dont call abstract'
  end

  def kbn_str
    raise 'dont call abstract'
  end

  def self.new_from_kbn_and_chip(kbn, chip)
    case kbn
    when ACT_KBN_NULL then return TernActionNull.new
    when ACT_KBN_FOLD then return TernActionFold.new
    when ACT_KBN_CALL then return TernActionCall.new(chip)
    when ACT_KBN_RAISE then return TernActionRaise.new(chip)
    when ACT_KBN_CALL_ALL_IN then return TernActionCallAllIn.new(chip)
    when ACT_KBN_RAISE_ALL_IN then return TernActionRaiseAllIn.new(chip)
    else
      raise 'invalid tern_action_kbn'
    end
  end
  def active?
    true
  end
  def raise?
    false
  end
end
