class User < ApplicationRecord
  has_many :room_users
  has_many :rooms, through: :room_users
  has_many :hand_users
  has_many :hands, through: :hand_users
end
