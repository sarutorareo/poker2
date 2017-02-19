class DlJudgeUserHandWinnerService 
  attr_accessor :winner_user_ids
  
  def initialize(hand_users, board)
    self.winner_user_ids = []
    @hand_users = hand_users
    @board = board
  end

  def do!()
    max_hand_users = []
    max_yaku = nil
    @hand_users.each do |hu|
      # foldしているなら
      next if hu.last_action.fold?
      current_yaku = hu.get_best_yaku(@board)
      ColorLog.clog current_yaku
      # 一人目なら
      if max_yaku.nil?
        max_yaku = current_yaku
        max_hand_users << hu
        next
      end

      comp_result = current_yaku.compare_to(max_yaku)
      # 記録更新なら
      if comp_result > 0
        max_yaku = current_yaku
        max_hand_users = []
        max_hand_users << hu
      # 引き分けなら
      elsif comp_result == 0
        max_hand_users << hu
      end
    end

    self.winner_user_ids = max_hand_users.map{|hu| hu.user_id}
  end
end

