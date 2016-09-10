class Hand < ApplicationRecord
  belongs_to :buttonUser, class_name: "User", foreign_key: "user_id"
  belongs_to :room
end
