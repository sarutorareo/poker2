class TernActionFold < TernAction
  def kbn
    ACT_KBN_FOLD
  end
  def kbn_str
    'fold'
  end
  def active?
    false
  end
end
