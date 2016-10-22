class TernActionFold < TernAction
  def kbn
    return ACT_KBN_FOLD
  end
  def kbn_str
    return 'fold'
  end
  def active?
    return false
  end
end
