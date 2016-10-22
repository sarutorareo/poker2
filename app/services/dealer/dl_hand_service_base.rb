class DlHandServiceBase
  
  def initialize(hand_id)
    @hand_id = hand_id
  end

  def do!()
    raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
  end
end

