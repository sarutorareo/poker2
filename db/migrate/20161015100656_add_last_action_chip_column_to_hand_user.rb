class AddLastActionChipColumnToHandUser < ActiveRecord::Migration[5.0]
  def change
    add_column :hand_users, :last_action_chip, :integer, :null => false, :default => 0
    
  end
end
