class DlJudgeUserHandWinnerService 
  attr_accessor :winner_user_ids
  
  def initialize(hand_users)
    self.winner_user_ids = []
    @hand_users = hand_users
  end

  def do!()
    max_hand_users = []
    @hand_users.each do |hu|
      # foldしているなら
      next if hu.last_action.fold?
      # 一人目なら
      if max_hand_users.blank?
        max_hand_users << hu
      # 記録更新なら
      elsif hu.user_hand.hicard_than?(max_hand_users[0].user_hand)
        max_hand_users = []
        max_hand_users << hu
      # 引き分けなら
      elsif !max_hand_users[0].user_hand.hicard_than?(hu.user_hand)
        max_hand_users << hu
      end
    end

    self.winner_user_ids = max_hand_users.map{|hu| hu.user_id}
  end
end

