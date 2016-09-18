class HandUser < ApplicationRecord
  belongs_to :hand
  belongs_to :user
  before_create { set_order }

private
  def set_order
    max_order = self.hand.get_max_hand_user_order
    self.tern_order = max_order + 1
  end
end
