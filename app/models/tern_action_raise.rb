class TernActionRaise < TernAction
  attr_reader :chip

  def initialize (chip)
    @chip = chip
  end
  def kbn
    return ACT_KBN_RAISE
  end
  def kbn_str
    return 'raise'
  end
end
