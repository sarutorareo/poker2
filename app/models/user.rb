class User < ApplicationRecord
  UT_HUMAN = 0
  UT_CPU = 1

  has_many :room_users
  has_many :rooms, through: :room_users
  has_many :hand_users
  has_many :hands, through: :hand_users

  after_initialize do
    if (self.user_type == UT_CPU)
      self.extend(CpuUser)
    end
  end

  def tern_action
    return nil
  end

  def is_cpu?
    return false
  end

    #ActionCable.server.broadcast "hand_user_channel_#{room_id}_#{user_id}", {type: "prompt_tern_action", DOM_prompt_tern_action: render_prompt_tern_action(user_id)}
#  private
#  def render_prompt_tern_action(user_id)
#    user = User.find(user_id)
#    return "#{user.name} tern";
#  end
end
