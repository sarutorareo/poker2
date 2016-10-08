class MsgUtil
  def self.msg_winners(winner_user_ids)
    if winner_user_ids.blank?
      return 'No Winner'
    end

    if winner_user_ids.is_a?(Integer)
      winner_user_ids = [winner_user_ids]
    end

    if winner_user_ids.count == 1
      result = 'Winner is '
    else
      result = 'Winners are '
    end
    winner_user_ids.each_with_index do |user_id, idx|
      user = User.find_by_id(user_id)
      result += ', '  if idx > 0
      result += user.name unless user.blank?
    end
    result += "!"
  end
end
