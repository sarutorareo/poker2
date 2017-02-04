class DlJudgeUserHandWinnerService 
  attr_accessor :winner_user_ids
  
  def initialize(hand_users)
    self.winner_user_ids = []
    @hand_users = hand_users
  end

  def do!()
    max_hand_users = []
    max_yaku = nil
    @hand_users.each do |hu|
      # foldしているなら
      next if hu.last_action.fold?
#TODO      current_yaku = hu.get_yaku
      current_yaku = YakuBase.new_from_str('SAS2S3S4S5')
      # 一人目なら
      if max_yaku.nil?
        max_yaku = current_yaku
        max_hand_users << hu
      # 記録更新なら
      elsif hu.user_hand.hicard_than?(max_hand_users[0].user_hand)
#      elsif current_yaku.compare_to(max_yaku) > 0
        max_yaku = current_yaku
        max_hand_users = []
        max_hand_users << hu
      # 引き分けなら
      elsif !max_hand_users[0].user_hand.hicard_than?(hu.user_hand)
#      elsif current_yaku.compare_to(max_yaku) == 0
        max_hand_users << hu
      end
    end

    self.winner_user_ids = max_hand_users.map{|hu| hu.user_id}
  end
end

