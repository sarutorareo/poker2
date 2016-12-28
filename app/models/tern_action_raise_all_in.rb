class TernActionRaiseAllIn < TernAction
  def initialize (chip)
    @chip = chip
  end
  def kbn
    ACT_KBN_RAISE_ALL_IN
  end
  def kbn_str
    'all_in(raise)'
  end
  def raise?
    true
  end
end
