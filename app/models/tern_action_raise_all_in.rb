class TernActionRaiseAllIn < TernAction
  def initialize (chip)
    @chip = chip
  end
  def kbn
    return ACT_KBN_RAISE_ALL_IN
  end
  def kbn_str
    return 'all_in(raise)'
  end
end
