class AddUserHandToHandUser < ActiveRecord::Migration[5.0]
  def change
    add_column :hand_users, :user_hand_str, :string
  end
end
