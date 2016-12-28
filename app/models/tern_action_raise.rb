class TernActionRaise < TernAction
  def initialize (chip)
    @chip = chip
  end
  def kbn
    ACT_KBN_RAISE
  end
  def kbn_str
    'raise'
  end
  def raise?
    true
  end
end
