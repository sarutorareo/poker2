class TernActionCallAllIn < TernAction
  def initialize (chip)
    @chip = chip
  end
  def kbn
    return ACT_KBN_CALL_ALL_IN
  end
  def kbn_str
    return 'all_in(call)'
  end
end
