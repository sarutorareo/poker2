class TernActionCall < TernAction
  attr_reader :chip

  def initialize (chip)
    @chip = chip
  end
  def kbn
    return ACT_KBN_CALL
  end
  def kbn_str
    return 'call'
  end
end
