class TernActionCall < TernAction
  def initialize (chip)
    @chip = chip
  end
  def kbn
    ACT_KBN_CALL
  end
  def kbn_str
    'call'
  end
end
