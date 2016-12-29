class TernActionCallAllIn < TernAction
  def initialize (chip)
    @chip = chip
  end

  def kbn
    ACT_KBN_CALL_ALL_IN
  end

  def kbn_str
    'all_in(call)'
  end

  def all_in?
    true
  end
end
